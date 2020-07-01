import React from "react"
import PropTypes from "prop-types"
import RegionDays from "./RegionDays"

class Provinces extends React.Component {
  render () {
    return (
      <div className="table-responsive">
        <table className="winners table table-bordered table-sm provinces">
          <thead>
            <tr>
              <th scope="col" />
              {this.props.provinces.map(province => (
                <th key={province.cbs_n} scope="col">
                  <a href={`/${ province.slug }`}>{ province.name }</a>
                </th>
              ))}
            </tr>
          </thead>
          <RegionDays days={ this.props.days } />
        </table>
      </div>
    );
  }
}

Provinces.propTypes = {
  provinces: PropTypes.array
};
export default Provinces
