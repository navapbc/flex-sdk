# Multi-Page Form Builder

The Multi-Page Form Builder enables developers to create complex forms that span multiple pages using field-tested design patterns from government applications. It provides a DSL for defining forms that follow best practices for accessibility, user experience, and data collection.

> [!NOTE]  
> The Flex Rules Engine is still a work in progress, and detailed documentation will be provided as the feature matures.

## Key Features

- **Easy to define and read**—Form flows are designed to be readable and maintainable, allowing developers to easily see how all the pages on the form are organized.
- **Supports looping pattern**—Supports gathering information about multiple people or items in a single or multi-page loop.
- **Automatically defined routes and controller actions**—Routes and controller actions for each of the form's pages are automatically generated.
- **Built-in views**—Prebuilt views that show the current page, current task/section, and overall progress of the form.
- **Customizable**—Routes, controller actions, and views are all customizable if the default behavior does not meet the application's needs.

## Design Principles

### Limit questions to one per page, where possible

The form builder encourages a one-question-per-page approach which:

- Through usability testing and secondary research, we’ve learned that taking a one-question-per-page approach increases people’s comfort and confidence and reduces their cognitive burden while moving through an application. 
- This approach is not a strict rule. In some cases, it might be a better user experience to pair some questions on the same page together, e.g., name and birth date.

### Break up large application forms into a task list

A task list page is used to introduce the application and show what's needed to complete it. As a user works on each "task", the task list page updates to reflect their progress through the application. 

A task might include:

- Answering a group of related questions
- Uploading documents
- Entering payment information

With the task list page, a user can review key details about the upcoming task so they know what to expect. Users can start, stop, and resume their progress in the application.

### Looping pattern for collecting information about multiple entities

When needing to collect a large amount of information about a person, or about multiple people, these questions may be asked in a loop.

There are 2 types of loops:

- Multi-page loops: information about one person spans multiple pages. Use this when there’s a lot of information to collect about someone that would be better broken up over multiple pages, and multiple people’s information would be gathered. For example, adding household members is a good use case for a multi-page loop since name, contact information, DOB, address etc. need to be collected for each person added.
- Single page loops: information about one person takes one full page. Use this when all the questions about one person in a series of people can be asked in one page without being too overwhelming for applicants.
