class Eventifier::Notifier
  def initialize klasses, *args
    # args will either be [:relation, {:on => :create}] or [{:relation => :second_relation, :on => :create}]
    # if its the first one, relation is the first in the array, otherwise treat the whole thing like a hash

    @klasses = klasses
    relation = args.delete_at(0) if args.length == 2
    args = args.first

    methods  = args.delete(:on)
    methods  = methods.kind_of?(Array) ? methods : [methods]
    relation ||= args

    @klasses.each do |target_klass|
      methods.each do |method_name|
        Eventifier::NotificationMapping.add "#{method_name}.#{target_klass.name.tableize}", relation
        Eventifier::NotificationSubscriber.subscribe_to_method target_klass, method_name
      end
    end
  end
end