import React from "react"
import PropTypes from "prop-types"

import ReactDOM from 'react-dom'

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
              <td key={index} className={ (case_count > 100 ? "bad" : case_count > 30 ? "mediocre" : case_count > 10 ? "better" : case_count > 0 ? "almost" :  case_count == 0 ? "good" : "correction") }>
                { case_count }
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    );
  }
}

RegionDays.propTypes = {
  days: PropTypes.array
};
export default RegionDays
