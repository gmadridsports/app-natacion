class DependencyInjection {
  late final Map<Type, Object> instances = {};

  static DependencyInjection? _instance;

  T getInstanceOf<T>() {
    if (instances[T] == null) {
      throw ArgumentError('Dependency not initialized');
    }
    print('antes que pete');
    print(instances[T]);
    return instances[T] as T;
  }

  DependencyInjection._hydrateWithInstances({List<(Type, Object)>? instances}) {
    instances?.forEach((instance) {
      this.instances[instance.$1] = instance.$2;
    });

    _instance = this;
  }

  factory DependencyInjection({List<(Type, Object)>? instances}) {
    if (_instance != null) {
      if (instances?.isNotEmpty ?? false) {
        throw ArgumentError('DependencyInjection already initialized');
      }

      return _instance as DependencyInjection;
    }

    if (instances == null) throw ArgumentError.notNull('TrainingRepository');

    return DependencyInjection._hydrateWithInstances(instances: instances);
  }
}
