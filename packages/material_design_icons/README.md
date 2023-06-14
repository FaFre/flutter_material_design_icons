# flutter_material_design_icons

This package provides over 7000+ material icons from the [Material Design Icons](https://materialdesignicons.com/) project.

All icons and fonts in this project are [licensed](https://pictogrammers.com/docs/general/license/) under Apache 2.0.

## Overview

![Icon Search App](https://fafre.github.io/flutter_material_design_icons/screenshots/app.png)

This package provides an `example/` which also comes in handy as a useful tool for searching and filtering icons included in this package.

The app is available for web [here](https://fafre.github.io/flutter_material_design_icons/icon_app/).

## Features

- **Preview icons in code editor**

  ![Icon preview](https://fafre.github.io/flutter_material_design_icons/screenshots/preview.png)

- **Deprecation notice**

  ![Deprecation](https://fafre.github.io/flutter_material_design_icons/screenshots/deprecated.png)

- **Metadata enriched**

  All icons are enriched with metadata derived from the MDI project like tags, styles, version and easily accessible via the icon `metadata` property.

- **Iterable**

  The icons are structured as an `enum` and can therefore be easily itegrated via `MdiIcons.values` for further processing or filtering in your application.

## Usage

You can use the MDI icons analog to the material icons shipped with flutter:

```dart
Icon(MdiIcons.abacus)
```
