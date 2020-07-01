import React from "react"
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
              <th key="header_left" className="date" />
              {this.props.municipalities.map(municipality => (
                <th key={municipality.slug}>{ mun_count > 12 ? municipality.short_name : municipality.name }</th>
              ))}
            </tr>
          </thead>
          <RegionDays days={ this.props.days } feeds={ this.props.municipalities.map(municipality => ({
            url: `/${ this.props.province.slug }/${ municipality.slug }.rss`,
            region: municipality.name,
            slug: municipality.slug
          }
          )) } />
        </table>
      </div>
    );
  }
}

Province.propTypes = {
  municipalities: PropTypes.array
};
export default Province
