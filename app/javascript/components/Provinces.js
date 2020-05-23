import React from "react"
import PropTypes from "prop-types"
import RegionDays from "./RegionDays"

class Provinces extends React.Component {
  render () {
    return (
      <table className="winners">
        <thead>
          <tr>
            <th />
            {this.props.provinces.map(province => (
              <th key={province.cbs_n}>{ province.name }</th>
            ))}
          </tr>
        </thead>
        <RegionDays days={ this.props.days } />
      </table>
    );
  }
}

Provinces.propTypes = {
  provinces: PropTypes.array
};
export default Provinces
