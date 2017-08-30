### Changes in 70300.11-Beta:

- Added: Item level on slots (#26, thanks to @bullsei)
- Added: Option to change the bank frame modifier
- Added: Option to toggle/delete categories (adding will come later)
- Added: Alternative font with russian glyphs
- Added: Custom dropdown for choosing item category per itemID (ctrl+right click a slot)
- Added: Multiple items to the teleport category database
- Changed: ruRU translations (thanks to @Devimax)
- Changed: deDE translations (thanks to @bullsei)
- Changed: koKR translations (thanks to @WetU)
- Changed: Artifact category now uses a new API to determine item type
- Changed: Update Interface version
- Fixed: Slot count on MainMenuBar not updating (#19)
- Fixed: Artifact Power total on the category frame for the layout
- Fixed: Issues with visibility when visiting vendors and banks
- Fixed: Issue where the auto-junk would not stop after leaving a vendor
- Fixed: Missing libraries when installed on its own

### Changes in 70100.10-Beta:

- Added: zhTW translations (thanks to @solor)
- Added: zhCN translations (thanks to @solor)
- Added: koKR translations (thanks to @WetU)
- Changed: deDE translations (thanks to @bullsei)
- Fixed: Incorrect paths for assets (packager issue)

### Changes in 70100.9-Beta:

- Added: Currency icons as a separate element
- Added: New bagslots icon
- Changed: Money module callbacks
- Changed: Currency module callbacks
- Fixed: Currencies drawn inproperly
- Fixed: Incorrect Artifact Power counter for german clients
- Fixed: Item link caching issues
- Fixed: Search module drawn below Currencies and Money
- Removed: Default positions for the Money module

### Changes in 70100.8-Beta:

- Added: Position lock/unlock toggle button
- Added: New icons to all the container buttons
- Added: UpdateTooltip method to container buttons
- Changed: Renamed the font file
- Changed: Restack tooltip string (requires localization update)
- Removed: Default container button texture handling
- Fixed: Modules' callbacks inconsistency
- Fixed: BagSlots not displaying properly
- Fixed: BagSlots alignment

### Changes in 70100.7-Beta:

- Added: deDE translations (thanks to @bullsei on GitHub!)
- Fixed: Errors due to missing savedvariables
- Fixed: Errors when changing bags during combat
- Fixed: Errors due to inaccuracy in blizzard API
- Removed: ItemLevel text (until I can figure out what's wrong with the API)

### Changes in 70100.6-Beta:

- Added: Proper position system
- Added: Item levels on equipment slots
- Added: Total amount of carried Artifact Power on the Artifact Power container title
- Added: PostCreateSlot callback
- Changed: Update Interface version
- Changed: Localizations are now defined directly in the addon, please contribute!
- Changed: Using GetItemInfoInstant for item classes and subclasses in categories filters
- Changed: PostUpdateSlot and PostRemoveSlot now pass the Slot instead of bagID and slotID
- Fixed: Containers going off the screen (they shift their columns now)
- Fixed: Item quality not representable
- Fixed: Font not moved to the layout
- Removed: Leaked global variable

### Changes in 70000.5-Beta:

- Fixed: More errors related to bank slots not existing
- Fixed: Bank not showing on first visit and Backpack was open

### Changes in 70000.4-Beta:

- Fixed: Errors related to (reagent) bank slots not existing

### Changes in 70000.3-Beta:

- Added: Deposit All Reagents button
- Added: Option to auto-deposit reagents when visiting a bank
- Added: Tooltips to all container buttons
- Added: Purchase button to the reagent bank container
- Added: Bag slots module
- Changed: Container buttons will hide unless useful (offline bank for example)
- Changed: Container buttons will arange on-demand
- Fixed: The default backpack being flagged as ignored
- Fixed: FreeSlot leaving an item on the cursor after clicked/dragged on/to
- Fixed: FreeSlot displaying tooltip for the first container

### Changes in 70000.2-Beta:

- Fixed: Layouts not being applied correctly

### Changes in 70000.1-Beta:

- First public release
