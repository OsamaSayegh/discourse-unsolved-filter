# name: discourse-unsolved-filter
# about: Creates an /unsolved route to display all unsolved topics
# version: 0.1
# authors: Osama Sayegh
# url: https://github.com/OsamaSayegh/discourse-unsolved-filter

Discourse.filters << :unsolved
Discourse.anonymous_filters << :unsolved

after_initialize do
  TopicQuery.class_eval do
    def list_unsolved
      create_list(:unsolved) do |topics|
        topics = topics.where("topics.id NOT IN (
          SELECT tc.topic_id
          FROM topic_custom_fields tc
          WHERE tc.name = 'accepted_answer_post_id' OR tc.name = 'accepted_answer_post_ids' AND tc.value IS NOT NULL
        )").where("topics.id NOT IN (
          SELECT cats.topic_id
          FROM categories cats WHERE cats.topic_id IS NOT NULL
        )")

        if !SiteSetting.allow_solved_on_all_topics
          topics = topics.where("topics.category_id IN (
            SELECT ccf.category_id
            FROM category_custom_fields ccf
            WHERE ccf.name = 'enable_accepted_answers' AND
            ccf.value = 'true'
          )")
        end
        topics
      end
    end
  end
end
