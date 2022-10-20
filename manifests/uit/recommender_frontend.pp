class profiles::uit::recommender_frontend (
  Boolean $deployment = true
)  inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    include ::profiles::uit::recommender_frontend::deployment

    Class['profiles::nodejs'] -> Class['profiles::uit::recommender_frontend::deployment']
  }

  # include ::profiles::uit::recommender_frontend::monitoring
  # include ::profiles::uit::recommender_frontend::metrics
  # include ::profiles::uit::recommender_frontend::backup
  # include ::profiles::uit::recommender_frontend::logging
}
