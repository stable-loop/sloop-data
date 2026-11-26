# sloop-data

A Rails gem providing a base controller, helpers, and reusable Haml views for CRUD resource management.

[![CI](https://github.com/stable-loop/sloop-data/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/stable-loop/sloop-data/actions/workflows/ci.yml)

## Contents

- [Installation from GitHub](#installation-from-github)
- [Creating a basic CRUD resource](#creating-a-basic-crud-resource)
- [Adding the data menu](#adding-the-data-menu)
- [Enabling user impersonation in a new app](#enabling-user-impersonation-in-a-new-app)
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

The partial checks the model's policy before showing a link, calls `data_icon_for(model_class)` in `Data::DataHelper` for the Bootstrap Icons class, and looks up the `model.models` translation key (for example, `widget.widgets`). The helper calls `bi_icon` on the matching data controller, which reads that controller's `BI_ICON` constant and falls back to `bi-table` if it is missing.

Define `BI_ICON` in each resource controller. `Data::ApplicationController` provides `bi_icon` and exposes it to views with `helper_method :bi_icon`:

```ruby
# app/controllers/data/widgets_controller.rb
class Data::WidgetsController < Data::ApplicationController
  BI_ICON = "bi-box"
end
```

Use the Bootstrap Icons class without adding the separate `bi` class.

## Enabling user impersonation in a new app

`sloop-data` declares `pretender` as a runtime dependency and loads it, so do not add a separate `pretender` entry to the application's `Gemfile`.

Add Pretender's setup to the host application's controller (merge this line into an existing controller rather than replacing it):

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  impersonates :user
end
```

Add routes for starting and stopping impersonation:

```ruby
# config/routes.rb
resources :users, only: [:index] do
  get :impersonate, on: :member
  get :stop_impersonating, on: :collection
end
```

Implement the actions in the host application's `UsersController`. Authenticate the caller and authorize impersonation before switching users:

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!

  def impersonate
    target_user = User.find(params[:id])
    authorize target_user
    impersonate_user(target_user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end
end
```

Make the action admin-only in the Pundit policy. `authorize target_user` uses the `impersonate?` query:

```ruby
# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def impersonate? = user.admin?
end
```

The gem provides `data/users/_extra_buttons.html.haml`, which adds an impersonation link to the standard user record buttons when the data users view is used. To show the stop-impersonating button in the navigation, render the provided partial inside a navigation list:

```haml
%ul.navbar-nav
  - if user_signed_in?
    = render "data/stop_impersonating"
```

Pretender also provides `true_user` for the authenticated user while `current_user` refers to the impersonated user. The host app remains responsible for its authentication, routes, controller actions, and authorization policy.

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
