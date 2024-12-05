# FlexSdk
The FlexSdk engine is primarily designed to simplify the implementation of complex workflows, with a focus on flexibility and extensibility.

This codebase consists of the Engine itself, and a "dummy" application within it to allow for testing.

The eligibility engine and similar code in `flex-sdk/lib/flex_sdk` is not yet integrated with with the stubbed workflows.

Overriding and customizing the eligibility engine is done via `.yml` files such as the one in `flex-sdk/test/dummy/config/pfml_rules.yml`

Currently implementing those customizations is done by importing the path to the `.yml` file in `flex-sdk/lib/flex_sdk/eligibility_engine.rb` -- This is not ideal. Importing the overrides should move elsewhere on later iterations.

## Getting Started

1. Install the Engine: Add `flex-sdk` to your Gemfile and run `bundle install`.

2. Run Migrations: Ensure the required database tables for tasks, processes, and applications are present.

3. Extend Models: Define additional task types or business processes as needed by inheriting from `Task` and `BusinessProcess`.

4. Subscribe to Events: Implement custom behavior by subscribing to `ActiveSupport::Notifications` events.

## Usage
In the dummy app, you can use classes defined in FlexSdk by calling them as follows:
`FlexSdk::ClassName.method_name(method_params)`

To test live in the dummy app, navigate to `test/dummy` and run `rails console`. From there, you can call any class within the engine using:
`FlexSdk::ClassName.method_name(method_params)`

ex: `FlexSdk::EligibilityEngine.evaluate({wages: 7000, hours_worked: 300}, {})`

## Further Reading
### Text Flow Diagram 

1. **Applicant** ➔ Submits **PaidLeaveApplication** ➔ Calls `submit` method.
2. **PaidLeaveApplication** ➔ Updates status to `"submitted"` ➔ Emits `application_submitted` event.
3. **ApplicationSubscriber** ➔ Receives event ➔ Creates **PaidLeaveApplicationBusinessProcess** ➔ Calls `run`.
4. **BusinessProcess** ➔ Creates initial **Tasks** (e.g., `FindEmploymentRecordTask`).
5. **Tasks** ➔ Executed individually ➔ May update application or process state.
6. **BusinessProcess** ➔ Monitors tasks ➔ Determines when the process is complete.

---

### Key Components Interaction

- **Models**:
  - `PaidLeaveApplication`: Represents the user's application; initiates the process upon submission.
  - `BusinessProcess`: Defines the workflow and manages tasks.
  - `Task`: Represents individual units of work within the process.

- **Notifications and Subscribers**:
  - **ActiveSupport::Notifications**: Used for decoupled communication between components.
  - `ApplicationSubscriber`: Listens to application events and initiates business processes.

- **Inheritance and Extensibility**:
  - Use of inheritance allows for easy extension of tasks and processes.
    - New task types can be created by inheriting from `Task`.
    - Custom business processes can be defined by inheriting from `BusinessProcess`.

---

### Extending the Workflow

- **Add New Task Types**:
  - Create new classes inheriting from `Task` to define additional units of work.
    ```ruby
    class VerifyEligibilityTask < FlexSdk::Task
      def perform
        # Custom logic for verifying eligibility
      end
    end
    ```

- **Customize Business Processes**:
  - Override the `run` method in your `BusinessProcess` subclass to define the sequence of tasks.
    ```ruby
    class CustomBusinessProcess < FlexSdk::BusinessProcess
      def run
        tasks.create!(type: "VerifyEligibilityTask")
        tasks.create!(type: "NotifyApplicantTask")
      end
    end
    ```

- **Handle Additional Events**:
  - Subscribe to more events or create new ones to react to different stages of the application lifecycle.
