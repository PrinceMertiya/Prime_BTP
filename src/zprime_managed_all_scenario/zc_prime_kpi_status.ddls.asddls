@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status KPI'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@UI.presentationVariant: [{
    qualifier: 'PV1',
    visualizations: [
      {
        type: #AS_CHART,
        qualifier: 'CHART1'
      }
    ]
}]

@UI.chart: [{
    qualifier: 'CHART1',
    chartType: #DONUT,
    dimensions: [ 'Status' ],
    measures: [ 'RequestCount' ]
}]

define view entity ZC_PRIME_KPI_STATUS
  as select from ZI_PRIME_KPI_STATUS
{
  key Status,
      RequestCount
}
