describe 'profiles::jenkins::node_labels' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title foobar" do
        let(:title) { 'foobar' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__jenkins__node_labels('foobar').with(
            'content' => []
          ) }

          it { is_expected.not_to contain_concat_fragment('jenkins-swarm-client_node-labels_foobar') }
        end

        context "with content => my_label" do
          let(:params) { {
            'content' => 'my_label'
          } }

          it { is_expected.to contain_concat_fragment('jenkins-swarm-client_node-labels_foobar').with(
            'target'  => 'jenkins-swarm-client_node-labels',
            'content' => 'my_label'
          ) }
        end

        context "with content => [label1, label2]" do
          let(:params) { {
            'content' => ['label1', 'label2']
          } }

          it { is_expected.to contain_concat_fragment('jenkins-swarm-client_node-labels_foobar').with(
            'target'  => 'jenkins-swarm-client_node-labels',
            'content' => "label1\nlabel2"
          ) }
        end
      end

      context "with title mylabels" do
        let(:title) { 'mylabels' }

        context "with content => baz" do
          let(:params) { {
            'content' => 'baz'
          } }

          it { is_expected.to contain_concat_fragment('jenkins-swarm-client_node-labels_mylabels').with(
            'target'  => 'jenkins-swarm-client_node-labels',
            'content' => 'baz'
          ) }
        end
      end
    end
  end
end
