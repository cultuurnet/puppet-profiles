define profiles::jenkins::node_labels (
  Variant[String,Array[String]] $content = []
) {

  include ::profiles

  unless empty($content) {
    concat::fragment { "jenkins-swarm-client_node-labels_${title}":
      target  => 'jenkins-swarm-client_node-labels',
      content => [$content].flatten.join("\n").downcase
    }
  }
}
