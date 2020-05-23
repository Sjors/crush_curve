import React from "react"
import PropTypes from "prop-types"
import RegionDays from "./RegionDays"

class Province extends React.Component {
  render () {
    const mun_count = this.props.municipalities.length;
    return (
      <table className="winners">
        <thead>
          <tr>
            <th className="date" />
            {this.props.municipalities.map(municipality => (
              <th className={ mun_count > 12 ? "long" : ""} key={municipality.cbs_n}>{ mun_count > 12 ? municipality.short_name : municipality.name }</th>
            ))}
          </tr>
        </thead>
        <RegionDays days={ this.props.days } />
      </table>
    );
  }
}

Province.propTypes = {
  municipalities: PropTypes.array
};
export default Province
