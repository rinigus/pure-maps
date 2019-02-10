Components in this platform folder can use the same imports as in the
main `qml` folder and it can be assumed to be linked from
platform-specific folder. Thus, its a generic components that are
shared among the platforms when some specific feature is not
available. For example, while Kirigami provides GlobalDrawer
(MenuDrawerPL specification), Silica and QtControls use a generic
PagePL that is filled to make it appear as a list of items.
