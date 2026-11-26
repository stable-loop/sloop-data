# sloop-data

A Rails gem providing a base controller, helpers, and reusable Haml views for CRUD resource management.

[![CI](https://github.com/stable-loop/sloop-data/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/stable-loop/sloop-data/actions/workflows/ci.yml)

## Contents

- [Installation from GitHub](#installation-from-github)
- [Creating a basic CRUD resource](#creating-a-basic-crud-resource)
- [Adding the data menu](#adding-the-data-menu)
- [Extending the templates with partials](#extending-the-templates-with-partials)
- [Replacing the standard views](#replacing-the-standard-views)
- [License](#license)

## Installation from GitHub

Add the gem to your application's `Gemfile`:

```ruby
gem "sloop-data", github: "stable-loop/sloop-data"
```

Install the dependencies:

```sh
bundle install
```

## Creating a basic CRUD resource

The base controller provides `index`, `show`, `new`, `edit`, `create`, `update`, and `destroy`. To create a CRUD resource for `Widget`, add the route:

```ruby
# config/routes.rb
namespace :data do
  resources :widgets
end
```

Create a controller that inherits from `Data::ApplicationController`:

```ruby
# app/controllers/data/widgets_controller.rb
class Data::WidgetsController < Data::ApplicationController
end
```

The controller name determines the model: `WidgetsController` uses `Widget`. The application must provide the model and its Pundit policy. The base controller uses `policy_scope` to list records, authorizes individual records, and gets `permitted_attributes` from the policy for create and update. The views also use `headers` for index columns and the `index?`, `new?`, `show?`, `edit?`, and `destroy?` permissions to decide which actions to display.

## Adding the data menu

`data/dropdown` is a navigation partial that builds links for resource controllers found under `app/controllers/data/` (excluding `application_controller` and `attachments_controller`). Render it inside your navigation list:

```haml
%ul.navbar-nav
  = render "data/dropdown"
```

The partial checks the model's policy before showing a link, uses `bi_icon` for the icon, and looks up the `model.models` translation key (for example, `widget.widgets`). Set the Bootstrap Icons class in the model's `BI_ICON` constant (without repeating the `bi` class):

```ruby
class Widget < ApplicationRecord
  BI_ICON = "bi-box"
end
```

The model's `bi_icon` class method should return this constant. If the application provides the same fallback as `ApplicationRecord`, models without `BI_ICON` use `bi-table` by default.

## Extending the templates with partials

To add resource-specific content, create partials under `app/views/data/<resource>/`. For example, for `WidgetsController`, use `app/views/data/widgets/`. Use the `.html.haml` format:

- `_extra_fields.html.haml`: inserted into the form after the standard fields. Receives `f` (the form builder) and `record`.
- `_extra_buttons.html.haml`: inserted alongside the standard buttons. Receives `record`.
- `_show_extra.html.haml`: inserted at the end of the details table. Receives `record`; add `%tr` rows to preserve the table structure.

Example of additional form fields:

```haml
-# app/views/data/widgets/_extra_fields.html.haml
.form-group
  = f.label :description
  = f.text_area :description
```

Example of additional details:

```haml
-# app/views/data/widgets/_show_extra.html.haml
%tr
  %th Description
  %td= record.description
```

These partials are rendered automatically when they exist at the path matching the controller.

## Replacing the standard views

The shared views are rendered from `data/index` and `data/show`. To replace them for all resources, create application views with the same virtual paths; application views take precedence over the gem's views:

- `app/views/data/index.html.haml` receives `list`.
- `app/views/data/show.html.haml` receives `record`.

To customize a single resource, override the action in its controller and render a resource-specific template. For example:

```ruby
class Data::WidgetsController < Data::ApplicationController
  def show
    render "data/widgets/show", locals: { record: @record }
  end

  def index
    render "data/widgets/index", locals: { list: @records }
  end
end
```

In that case, place the templates at `app/views/data/widgets/show.html.haml` and `app/views/data/widgets/index.html.haml`, respectively.

## License

Under [MIT License](https://opensource.org/license/MIT)

Copyright (c) 2026 [Stableloop](https://stableloop.dev).
