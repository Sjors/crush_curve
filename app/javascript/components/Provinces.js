import React from "react"
import PropTypes from "prop-types"
import RegionDays from "./RegionDays"

class Provinces extends React.Component {
  render () {
    const wave = this.props.wave == 2 ? "" : `/wave/${ this.props.wave }`
    return (
      <div className="table-responsive">
        <table className="winners table table-bordered table-sm provinces">
          <thead>
            <tr>
              <th scope="col" />
              {this.props.provinces.map(province => (
                <th key={province.cbs_n} scope="col">
                  <a href={ `${ wave }/${ province.slug }` }>{ province.name }</a>
                </th>
              ))}
            </tr>
          </thead>
          <RegionDays days={ this.props.days } />
          <tfoot>
            <tr><td></td></tr>
            <tr>
              <td scope="col" />
              {this.props.provinces.map(province => (
                <td key={province.cbs_n} scope="col">
                  <a href={ `${ wave }/${ province.slug }` }>{ province.name }</a>
                </td>
              ))}
            </tr>
          </tfoot>
        </table>
      </div>
    );
  }
}

Provinces.propTypes = {
  provinces: PropTypes.array
};
export default Provinces
