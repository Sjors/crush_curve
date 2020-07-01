import React from "react"
import Feed from "./Feed"
import PropTypes from "prop-types"
import RegionDays from "./RegionDays"

class Province extends React.Component {
  render () {
    const mun_count = this.props.municipalities.length;
    return (
      <div className="table-responsive">
        <table key={ this.props.province.slug } className="winners table table-bordered table-sm">
          <thead key="head">
            <tr key="header">
              <th key="header_left" className="date">
                <a href={ "/" }>Home</a>
              </th>
              {this.props.municipalities.map(municipality => (
                <th key={municipality.slug}>{ mun_count > 12 ? municipality.short_name : municipality.name }</th>
              ))}
            </tr>
          </thead>
          <RegionDays days={ this.props.days } />
          <tfoot>
            <tr><td></td></tr>
            <tr>
              <td />
              {this.props.municipalities.map(municipality => (
                <Feed key={ municipality.slug } province={ this.props.province } municipality={ municipality } />
              ))}
            </tr>
          </tfoot>
        </table>
      </div>
    );
  }
}

Province.propTypes = {
  municipalities: PropTypes.array
};
export default Province
