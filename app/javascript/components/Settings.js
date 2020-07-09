import React from "react"

import ReactDOM from 'react-dom'

import axios from 'axios';

axios.defaults.headers.post['Content-Type'] = 'application/json'

class Settings extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      authToken: window.localStorage.getItem('auth_token')
    };

    const genRanHex = size => [...Array(size)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');

    if (this.state.authToken === null) {
      const authToken = genRanHex(64)
      window.localStorage.setItem('auth_token', authToken)
      this.setState({authToken: authToken})
    }

    this.props.onChange({subscriptions: JSON.parse(window.localStorage.getItem('subscriptions')) || []})
  }

  static checkPermission(authToken) {
    return new Promise((resolve, reject) => {
      if (window.safari.pushNotification.permission('web.nl.pletdecurve') == "granted") {
        resolve()
      }
      window.safari.pushNotification.requestPermission(
        'https://pletdecurve.nl/push',
        'web.nl.pletdecurve',
        {auth_token: authToken},
        permissionData => {
          if (permissionData.permission === 'default') {
            // This should not happen
            reject()
          } else if (permissionData.permission === 'denied') {
            reject()
          } else if (permissionData.permission === 'granted') {
            resolve()
          }
        }
    )
    })
  }

  static subscribe(authToken, newSubscriptions, currentSubscriptions) {
    Settings.checkPermission(authToken).then(() => {
      newSubscriptions.forEach(s => {
        axios.post('/subscriptions',{
          municipality_id: s
        }, {
          headers: {
            'Authorization': `Basic ${authToken}`
          }
        }).then(response => {
          // State is optimistically updated when the user clicks on the notification.
          // We just need to update localStorage. Do this synchronously, since we
          // don't know in what order the server responses come in:
          const subscriptions = JSON.parse(window.localStorage.getItem('subscriptions')) || [];
          window.localStorage.setItem('subscriptions', JSON.stringify(subscriptions.concat([s])))
        }).catch(error => {
          // TODO move non-static method, so we can update state
          alert("Unable to subscribe, refresh page and try again later")
          console.error(error)
        })
      })
    }).catch(() => {
      alert("No permission from browser, subscription failed.")
    })

  }

  static unsubscribe(authToken, removedSubscriptions, currentSubscriptions) {
    removedSubscriptions.forEach(s => {
      axios.delete(`/subscriptions/${ s }`, {
        headers: {
          'Authorization': `Basic ${authToken}`
        }
      }).then(response => {
        // State is optimistically updated when the user clicks on the notification.
        // We just need to update localStorage. Do this synchronously, since we
        // don't know in what order the server responses come in:
        const subscriptions = JSON.parse(window.localStorage.getItem('subscriptions')) || [];
        window.localStorage.setItem('subscriptions', JSON.stringify(subscriptions.filter(e => {
          return e !== s
        })))
      }).catch(error => {
        // TODO move non-static method, so we can update state
        alert("Unable to unsubscribe, refresh page and try again later, or disable notifications for this site in Safari")
        console.error(error)
      })
    })
  }

  static getDerivedStateFromProps(props, state) {
    if (state.subscriptions) {
      if (props.subscriptions.length > state.subscriptions.length) {
        Settings.subscribe(state.authToken, props.subscriptions.filter(x => !state.subscriptions.includes(x)), state.subscriptions)
      } else if (props.subscriptions.length < state.subscriptions.length) {
        Settings.unsubscribe(state.authToken, state.subscriptions.filter(x => !props.subscriptions.includes(x)), state.subscriptions)
      }
    }
    state.subscriptions = props.subscriptions;
    return state;
  }

  render () {
    return null
  }


}

export default Settings
