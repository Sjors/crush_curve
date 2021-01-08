import React from "react"
import PropTypes from "prop-types"

import ReactDOM from 'react-dom'

class RegionDays extends React.Component {
  transpose = m => m[0].map((x,i) => m.map(x => x[i]))
  sum = (total, num) => total + num

  render () {
    return (
      <tbody>
        {this.props.days.map(day => (
          <tr key={ day.date }>
            <td className="date" key={ day.date + "-title" }>
              { day.date }
            </td>
            {this.transpose([day.cases,day.cases_24,day.municipality_cancelled || false]).map((case_count, index) => (
              <td key={index} className={ (case_count[2] ? "municipality_cancelled" : day.recent ? "recent" : case_count[0] > 500 ? "severe" : case_count[0] > 100 ? "bad" : case_count[0] > 30 ? "mediocre" : case_count[0] > 10 ? "better" : case_count[0] > 0 ? "almost" :  case_count[0] == 0 ? "good" : "correction") }>
                { case_count[0] }
                {
                  case_count[1] > 0 &&
                  ` (${case_count[1]})`
                }
              </td>
            ))}
            <td>
              {day.cases.reduce(this.sum, 0)}
            </td>
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
