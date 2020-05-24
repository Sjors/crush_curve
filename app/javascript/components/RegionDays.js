import React from "react"
import PropTypes from "prop-types"

import ReactDOM from 'react-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faRss } from '@fortawesome/free-solid-svg-icons'

class RegionDays extends React.Component {
  render () {
    return (
      <tbody>
        {this.props.days.map(day => (
          <tr key={ day.date }>
            <td className="date" key={ day.date + "-title" }>
              { day.date }
            </td>
            {day.cases.map((case_count, index) => (
              <td key={index} className={ case_count > 100 ? "bad" : case_count > 30 ? "mediocre" : case_count > 10 ? "better" : case_count > 0 ? "almost" : "good" }>
                { case_count }
              </td>
            ))}
          </tr>
        ))}
        <tr key="feed_spacer" />
        { this.props.feeds &&
          <tr>
            <td />
            {this.props.feeds.map(feed =>(
              <td key={ `feed_${ feed.slug }` } className="notifications">
                <a href={ feed.url } target="_blank">
                  <div className="tooltip"><FontAwesomeIcon icon={faRss} />
                    <span className="tooltiptext">RSS feed voor bevestigde besmettingen in { feed.region }</span>
                  </div>
                </a>
              </td>
            ))}
          </tr>
        }
      </tbody>
    );
  }
}

RegionDays.propTypes = {
  days: PropTypes.array
};
export default RegionDays
