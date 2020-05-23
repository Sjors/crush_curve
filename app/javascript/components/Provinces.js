import React from "react"
import PropTypes from "prop-types"
class Provinces extends React.Component {
  render () {
    return (
      <ul>
        {this.props.provinces.map(province => (
          <li key={province.cbs_n}>{ province.name }</li>
        ))}
      </ul>
    );
  }
}

Provinces.propTypes = {
  provinces: PropTypes.array
};
export default Provinces
