import React from "react"
import PropTypes from "prop-types"
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faRss } from '@fortawesome/free-solid-svg-icons'

class Feed extends React.Component {
  render () {
    return (
      <td key={ `feed_${ this.props.municipality.slug }` } className="notifications" align="left">
        <a href={ `/${ this.props.province.slug }/${ this.props.municipality.slug }.rss` } target="_blank">
          <span data-toggle="tooltip" title={`RSS feed voor bevestigde besmettingen in ${ this.props.municipality.name }`}>
            <FontAwesomeIcon icon={faRss} />
          </span>
        </a> { this.props.municipality.name }
      </td>
    )
  }
}

Feed.propTypes = {
  municipality: PropTypes.object,
  provice: PropTypes.object
};
export default Feed
