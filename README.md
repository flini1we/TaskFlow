# Task Flow

Task Flow is an elegant and intelligent task management application designed to streamline your personal and professional life.  Built with a focus on user experience, Task Flow leverages a hybrid MVVM architecture, seamlessly blending UIKit and SwiftUI to deliver a beautiful and intuitive interface.  It also incorporates powerful frameworks like `SPLarkController` and `Charts` to provide advanced features and visualizations.

## Features

Task Flow is packed with features designed for efficiency and a delightful user experience.  Here's a breakdown of the key components and technologies used:

**Core Functionality & Architecture:**

*   **Hybrid UI (UIKit & SwiftUI):**  Combines the strengths of both frameworks for optimal performance and flexibility.
*   **MVVM Architecture:**  Ensures a clean separation of concerns, leading to maintainable and testable code.
*   **Core Data:**  Provides robust and persistent data storage for your tasks.
*   **`Result` Type for Error Handling:**  Employs the `Result` type for clean and consistent error management, using a custom `enum` for Core Data errors.
*   **Context Merging:**  Demonstrates advanced Core Data techniques with context merging for efficient data handling.
*   **`NSFetchedResultsController`:** Powers the Statistics screen, efficiently fetching and managing completed task data.

**Screen-Specific Highlights:**

*   **Main Screen (Task List):**
    *   **Dynamic UI Updates:**  Uses `NotificationCenter` observers to update the accent color and `keyBoardObserver` to manage the tab bar's visibility.
    *   **Customizable Header:**  Features a custom `toolBar` (header view) with gesture and button handling.
    *   **Interactive Task Management:**  Implements `UITableViewDragDelegate` and `UITableViewDropDelegate` for intuitive task reordering.
    *   **Inline Editing:**  Allows direct task editing via a `UITextField` within the `UITableViewCell`.
    *   **Smooth Animations:**  Employs `CAShapeLayer` for visually appealing checkmark animations.
    *   **Efficient Data Display:**  Utilizes `UITableViewDiffableDataSource` with snapshots for optimized table view updates.
    *   **Scroll-Based UI Changes:**  Leverages the `UIScrollViewDelegate` to dynamically adjust the UI based on scroll position.

*   **Settings Screen:**
    *   **Accent Color Customization:**  Provides a `UICollectionView` to select and persist the app's accent color using `UserDefaults`.
    *   **Real-time UI Updates:**  Uses `NotificationCenter` to instantly reflect the chosen accent color throughout the app.

*   **Statistics Screen:**
    *   **Data Visualization with Charts:**  Integrates the `Charts` framework (SwiftUI) to present completed task data in a visually engaging manner.
    *   **Dynamic Table View:**  Adjusts the table view height dynamically based on content.
    *   **SwiftUI State Management:**  Uses `@Environment` and `@Published` property wrappers for efficient data flow and UI updates.

*   **Todo Detail Screen:**
    *   **Custom Presentation:**  Uses `UIPresentationController` and `UIViewControllerTransitioningDelegate` to display a concise pop-over view with task details.

**Additional Features:**

*   **`feedBackService`:**  Provides haptic feedback (vibration) for a more tactile user experience.

**Gifs**

[gif](https://github.com/user-attachments/assets/017d33fc-5a61-413d-9d2e-3ac88ab65c1e)

[gif](https://github.com/user-attachments/assets/97ffb800-da24-4a96-88f8-9c6dcc494561)

[gif](https://github.com/user-attachments/assets/1ab5824f-316a-4ee5-8bc2-d19bdb04388f)

[gif](https://github.com/user-attachments/assets/9a86c985-e88c-403e-996f-792bb4286b91)

[gif](https://github.com/user-attachments/assets/fe6d1448-0007-42be-8bf7-2dc85dc73d88)

[gif](https://github.com/user-attachments/assets/08d0c30b-346d-45fc-8451-f736978e7aa1)

[gif](https://github.com/user-attachments/assets/7d743e33-7664-4506-9022-e8c9b024d318)

[gif](https://github.com/user-attachments/assets/acad3ecf-3271-44b3-ad9e-ece7e8934448)

[gif](https://github.com/user-attachments/assets/19671f0b-87a9-47c2-89a8-a58d55a5bb86)

## Requirements

*   iOS 14.0+
*   Xcode 12.0+
*   Swift 5.3+

## Contact

For questions, suggestions, or feedback, please reach out to us at: zabinskiy.danil@mail.ru
