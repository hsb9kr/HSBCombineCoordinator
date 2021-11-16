import Foundation
import Combine

open class BaseCoordinator<ResultType> {
	private let identifier = UUID()
	private var childCoordinators = [UUID: Any]()
	public var cancellables: Set<AnyCancellable> = []
	
	private func store<T>(coordinator: BaseCoordinator<T>) {
		childCoordinators[coordinator.identifier] = coordinator
	}
	
	private func free<T>(coordinator: BaseCoordinator<T>) {
		childCoordinators[coordinator.identifier] = nil
	}
	
	public func coordinate<T>(to coordinator: BaseCoordinator<T>) -> AnyPublisher<T, Never> {
		store(coordinator: coordinator)
		return coordinator
			.start()
			.handleEvents(receiveOutput: { [weak self] _ in
				self?.free(coordinator: coordinator)
			})
			.eraseToAnyPublisher()
	}
	
	open func start() -> AnyPublisher<ResultType, Never> {
		fatalError("Start method should be implemented.")
	}
}
