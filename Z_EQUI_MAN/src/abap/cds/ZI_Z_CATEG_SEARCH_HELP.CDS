//" No view enhancement allowed for this CDS
@AbapCatalog.viewEnhancementCategory: [#NONE]

//" No authorization required for value help usage
@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Search Help for category'

//" Ignore annotations propagated from underlying data source
@Metadata.ignorePropagatedAnnotations: true

//" Small and static result set expected
@ObjectModel.resultSet.sizeCategory: #XS

//" Value help view based on custom domain values
define view entity Z_CATEG_SEARCH_HELP
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE(
                    p_domain_name : 'ZCATEG_DOMAIN') as Values

//" Join with text table for language-dependent descriptions
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                    p_domain_name : 'ZCATEG_DOMAIN') as Texts
      on  Texts.domain_name    = Values.domain_name
      and Texts.value_position = Values.value_position
      and Texts.language       = $session.system_language
{
  key Values.value_low as value,
      Texts.text       as text
}
