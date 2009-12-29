# raw_ads =
#   LOAD '$INPUT/ads*'
#   USING PigStorage AS (
#     ad_id:chararray,
#     api_key:chararray,
#     name:chararray,
#     dimensions:chararray,
#     destination:chararray,
#     agent_version:chararray
#   );
raw_ads = load(
  '$INPUT/ads*',
  :using => :pig_storage,
  :schema => %w(ad_id api_key name dimensions destination agent_version)
)

# ads =
#   FOREACH
#     (GROUP raw_ads BY ad_id PARALLEL $PARALLELISM)
#   GENERATE
#     $0 AS ad_id,
#     MAX($1.api_key) AS api_key,
#     MAX($1.name) AS name,
#     MAX($1.dimensions) AS dimensions,
#     MAX($1.destination) AS destination,
#     MAX($1.agent_version) AS agent_version
#   ;
ads = raw_ads.group(:ad_id, :parallel => 2).foreach do |relation|
  [
    relation[0].as(:ad_id),
    relation[1].api_key.as(:api_key)
    relation[1].name.max.as(:name)
    relation[1].dimensions.max.as(:dimensions)
    relation[1].destination.max.as(:destination)
    relation[1].agent_version.max.as(:agent_version)
  ]
end

# STORE ads INTO '$OUTPUT/ads' USING PigStorage;
store(ads, '$OUTPUT/ads', :using => :pig_storage)