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
