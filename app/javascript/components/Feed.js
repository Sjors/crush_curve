import React from "react"
import PropTypes from "prop-types"
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faRss } from '@fortawesome/free-solid-svg-icons'
import { faBell } from '@fortawesome/free-solid-svg-icons'

class Feed extends React.Component {
  constructor(props) {
    super(props);
    this.subscribe = this.subscribe.bind(this);
    this.unsubscribe = this.unsubscribe.bind(this);
  }

  subscribe () {
    this.props.onChange({
      subscriptions: this.props.subscriptions.concat([this.props.municipality.id])
    })
  }

  unsubscribe () {
    this.props.onChange({
      subscriptions: this.props.subscriptions.filter(e => {
        return e !== this.props.municipality.id
      })
    })
  }

  render () {
    const safariNotifications = 'safari' in window && 'pushNotification' in window.safari
    const isSubscribed = this.props.subscriptions && this.props.subscriptions.indexOf(this.props.municipality.id) != -1

    return (
      <td key={ `feed_${ this.props.municipality.slug }` } className="notifications" align="left">
        <a href={ `/${ this.props.province.slug }/${ this.props.municipality.slug }.rss` } target="_blank">
          <span data-toggle="tooltip" title={`RSS feed voor bevestigde besmettingen in ${ this.props.municipality.name }`}>
            <FontAwesomeIcon icon={faRss} />
          </span>
        </a>
        &nbsp;
        { safariNotifications &&
          <span>
            <span data-toggle="tooltip" title={`Safari push bericht voor ${ this.props.municipality.name }`}>
              <FontAwesomeIcon icon={faBell} onClick={ !isSubscribed ? this.subscribe : this.unsubscribe } color={ isSubscribed ? "green" : "black" } />
            </span>
            &nbsp;
          </span>
        }
        { this.props.municipality.name }
      </td>
    )
  }
}

Feed.propTypes = {
  municipality: PropTypes.object,
  provice: PropTypes.object,
  subscriptions: PropTypes.array,
  onChange: PropTypes.func
};
export default Feed
