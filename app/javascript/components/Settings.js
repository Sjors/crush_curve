import React from "react"

import ReactDOM from 'react-dom'

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

  static getDerivedStateFromProps(props, state) {
    if (state.subscriptions) {
      if (props.subscriptions.length > state.subscriptions.length) {
        console.log("New subscription(s):", props.subscriptions.filter(x => !state.subscriptions.includes(x)))
        window.localStorage.setItem('subscriptions', JSON.stringify(props.subscriptions))
      } else if (props.subscriptions.length < state.subscriptions.length) {
        console.log("Removed subscription(s):", state.subscriptions.filter(x => !props.subscriptions.includes(x)))
        window.localStorage.setItem('subscriptions', JSON.stringify(props.subscriptions))
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
