using System;

using Foundation;
using AppKit;
using CoreGraphics;
using RestSharp;
using System.Threading;
using System.Text.RegularExpressions;
using System.Collections.Generic;

namespace MALLibrary
{
	public partial class MainWindowController : NSWindowController
	{

		int aniinfoid = 0;
		NSDictionary currentaniinfo;
		NSArray seasonindex;
		public MyAnimeList malengine { get; set; }
		public AppDelegate appdel { get; set; }
		int selectedlisteditid = 0;
		bool selectedlistairing = false;
		int selectedaddtitleid = 0;
		public MainWindowController(IntPtr handle) : base(handle)
		{
		}


		[Export("initWithCoder:")]
		public MainWindowController(NSCoder coder) : base(coder)
		{
		}

		public MainWindowController() : base("MainWindow")
		{
		}

		public override void AwakeFromNib()
		{
			base.AwakeFromNib();
			// Use Unified Toolbar Title Bar
			base.Window.TitleVisibility = NSWindowTitleVisibility.Hidden;
			base.Window.SetFrame(base.Window.Frame, true);
			// Fix TextView text color
			backgroundtextview.TextColor = NSColor.ControlText;
			detailstextview.TextColor = NSColor.ControlText;
			synopsistextview.TextColor = NSColor.ControlText;
			// Set Main Views to be resizable
			searchview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			listview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			animeinfoview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			progressview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			seasonsview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			listloggedoutview.AutoresizingMask = NSViewResizingMask.HeightSizable | NSViewResizingMask.WidthSizable;
			//Set up list view
			sourcelist.Initialize();
			generatesourcelist();
			performappearencechange();
			//Load List
			if (Keychain.checkacountexists() == true)
			{
				performloadlist(false);
			}
			else
			{
				loggedinuser.StringValue = "Not logged in";
			}
		}
		private void generatesourcelist()
		{
			var library = new SourceListItem("LIBRARY");
			library.AddItem("Anime List", NSImage.ImageNamed("library"), loadmainview);
			sourcelist.AddItem(library);
			var discover = new SourceListItem("DISCOVER");
			discover.AddItem("Search", NSImage.ImageNamed("search"), loadmainview);
			discover.AddItem("Title Info", NSImage.ImageNamed("animeinfo"), loadmainview);
			discover.AddItem("Seasons", NSImage.ImageNamed("seasons"), loadmainview);
			sourcelist.AddItem(discover);

			// Display side list
			sourcelist.ReloadData();
			sourcelist.ExpandItem(null, true);

			// Retrieve last used main view
			if (NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedmainview")) != null)
			{
				NSNumber selected = (NSNumber)NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedmainview"));
				sourcelist.SelectRow(selected.NIntValue, false);
			}
			else
			{
				sourcelist.SelectRow(1, false);
			}
		}

		public void loadmainview()
		{
			// Loads the view based on the selection from the source list
			CGRect mainviewframe = mainview.Frame;
			mainview.AddSubview(new NSView());
			nint selectedrow = sourcelist.SelectedRow;
			CGPoint origin = new CGPoint();
			origin.X = 0;
			origin.Y = 0;
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					if (Keychain.checkacountexists() == true)
					{
						mainview.ReplaceSubviewWith(mainview.Subviews[0], listview);
						listview.Frame = mainviewframe;
						listview.SetFrameOrigin(origin);

					}
					else
					{
						mainview.ReplaceSubviewWith(mainview.Subviews[0], listloggedoutview);
						listloggedoutview.Frame = mainviewframe;
						listloggedoutview.SetFrameOrigin(origin);
					}
					break;
				case "Search":
					mainview.ReplaceSubviewWith(mainview.Subviews[0], searchview);
					searchview.Frame = mainviewframe;
					searchview.SetFrameOrigin(origin);
					listview.SetFrameOrigin(origin);
					break;
				case "Title Info":
					if (aniinfoid != 0)
					{
						mainview.ReplaceSubviewWith(mainview.Subviews[0], animeinfoview);
						animeinfoview.Frame = mainviewframe;
						animeinfoview.SetFrameOrigin(origin);
					}
					else
					{
						mainview.ReplaceSubviewWith(mainview.Subviews[0], progressview);
						progressview.Frame = mainviewframe;
						progressview.SetFrameOrigin(origin);
						noinfo.Hidden = false;
						loadingwheel.Hidden = true;
					}
					break;
				case "Seasons":
					mainview.ReplaceSubviewWith(mainview.Subviews[0], seasonsview);
					seasonsview.Frame = mainviewframe;
					seasonsview.SetFrameOrigin(origin);
					break;
			}
			createtoolbar();
			// Save Current Main View
			NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSNumber(sourcelist.SelectedRow), new NSString("selectedmainview"));
		}
		public void createtoolbar()
		{
			// Shows toolbar items based on current main view.
			NSToolbarItem[] items = toolbar.Items;
			if (items != null)
			{
				for (nint i = 0; i < items.Length; i++)
				{
					toolbar.RemoveItem(0);
				}
			}
			// Create toolbar
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					if (Keychain.checkacountexists() == true)
					{
						toolbar.InsertItem("editList", 0);
						toolbar.InsertItem("DeleteTitle", 1);
						toolbar.InsertItem("refresh", 2);
						toolbar.InsertItem("ShareList", 3);
						toolbar.InsertItem("NSToolbarFlexibleSpaceItem", 4);
						toolbar.InsertItem("filter", 5);
					}
					break;
				case "Search":
					toolbar.InsertItem("AddTitleSearch", 0);
					toolbar.InsertItem("NSToolbarFlexibleSpaceItem", 1);
					toolbar.InsertItem("search", 2);
					break;
				case "Title Info":
					if (aniinfoid != 0)
					{
						if (checkiftitleexistsonlist(aniinfoid) == true)
						{
							toolbar.InsertItem("editInfo", 0);
						}
						else
						{
							toolbar.InsertItem("AddTitleInfo", 0);
						}
						toolbar.InsertItem("viewonmal", 1);
						toolbar.InsertItem("ShareInfo", 2);
					}
					break;
				case "Seasons":
					toolbar.InsertItem("AddTitleSeason", 0);
					toolbar.InsertItem("yearselect", 1);
					toolbar.InsertItem("seasonselect", 2);
					toolbar.InsertItem("refresh", 3);
					if (seasonindex == null)
					{
						retrieveseasonindex(false);
					}
					break;
			}
		}

		public new MainWindow Window
		{
			get { return (MainWindow)base.Window; }
		}
		// Toolbar Functions
		partial void performfilter(Foundation.NSObject sender)
		{
			filterlist();
		}
		partial void performrefresh(Foundation.NSObject sender)
		{
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					performloadlist(true);
					return;
				case "Seasons":
					performseasondatarefresh();
					break;
			}
		}
		partial void opensharemenu(Foundation.NSObject sender)
		{
			// Share Menu
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			NSObject[] shareitems = new NSObject[2];
			// Generate share items based on which view the Share button has been pressed.
			switch (selecteditem.Title)
			{
				case "Anime List":
					NSDictionary d = (NSDictionary)animelistarraycontroller.SelectedObjects[0];
					NSNumber idnum = (NSNumber)d.ValueForKey(new NSString("id"));
					string title = (NSString)d.ValueForKey(new NSString("title")).ToString();
					shareitems[0] = new NSString("Check " + title + " out - ");
					shareitems[1] = new NSUrl("https://myanimelist.net/anime/" + idnum.Int32Value);
					break;
				case "Title Info":
					shareitems[0] = new NSString("Check " + animeinfotitle.StringValue + " out - ");
					shareitems[1] = new NSUrl("https://myanimelist.net/anime/" + aniinfoid);
					break;
			}
			NSSharingServicePicker picker = new NSSharingServicePicker(shareitems);
			NSButton btn = (NSButton)sender;
			picker.ShowRelativeToRect(btn.Bounds, btn, NSRectEdge.MinYEdge);
		}
		partial void addtitle(Foundation.NSObject sender)
		{
			// Checks if title exist
			if (Keychain.checkacountexists() == false)
			{
				showneedaccountdialog();
				return;
			}
			// Shows Add Title Popover
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			NSDictionary d = new NSDictionary();
			NSString sid;
			NSData data;
			NSError e;
			switch (selecteditem.Title)
			{
				case "Search":
					d = (NSDictionary)searcharraycontroller.SelectedObjects[0];
					sid = (NSString)d.ValueForKey((NSString)"id").ToString();
					// Deserialize data
					data = NSData.FromString(malengine.loadanimeinfo(Convert.ToInt32(sid)).Content);
					d = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
					data.Dispose();
					break;
				case "Title Info":
					d = currentaniinfo;
					break;
				case "Seasons":
					d = (NSDictionary)seasonarraycontroller.SelectedObjects[0];
					d = (NSDictionary)d.ValueForKey((NSString)"id");
					sid = (NSString)d.ValueForKey((NSString)"id").ToString();
					// Deserialize data
					 data = NSData.FromString(malengine.loadanimeinfo(Convert.ToInt32(sid)).Content);
					d= (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
					data.Dispose();
					break;
			}
			NSNumber id = (NSNumber)d.ValueForKey((NSString)"id");
			addtitlelbl.StringValue = (NSString)d.ValueForKey((NSString)"title");
			if (checkiftitleexistsonlist(id.Int32Value) == true)
			{
				addtitleview.Hidden = true;
				addtitleexists.Hidden = false;
			}
			else
			{
				string airstatus = (NSString)d.ValueForKey((NSString)"status").ToString();
				if (airstatus == "finished airing")
				{
					selectedlistairing = false;
				}
				else
				{
					selectedlistairing = true;
				}
				addtitleview.Hidden = false;
				addtitleexists.Hidden = true;
				selectedaddtitleid = id.Int32Value;
				addpopoverepifield.StringValue = "0";
				NSNumber episodes = (NSNumber)d.ValueForKey((NSString)"episodes");
				if (episodes.Int16Value > 0)
				{
					addpopoverformat.Maximum = episodes;
				}
				else
				{
					addpopoverformat.Maximum = null;
				}
				addpopovertotal.StringValue = episodes.ToString();
				addpopoverstatus.Title = "watching";
				addpopoverscore.SelectItemWithTag(0);
				selectedaddtitleid = id.Int32Value;
				addprogressview.Hidden = true;
			}
			NSButton btn = (NSButton)sender;
			addpopover.Show(btn.Bounds, btn, NSRectEdge.MaxYEdge);
		}
		partial void addpopoveraddtitle(Foundation.NSObject sender)
		{
			// Set UI
			addprogressview.StartAnimation(sender);
			addprogressview.Hidden = false;
			addpopover.Behavior = NSPopoverBehavior.ApplicationDefined;
			// Validate update data
			if (addpopoverepifield.StringValue == addpopovertotal.StringValue && addpopovertotal.StringValue != "0" && addpopoverstatus.Title != "completed")
			{
				addpopoverstatus.Title = "completed";
			}
			if (selectedlistairing == true && addpopoverstatus.Title == "completed")
			{
				//Invalid
				addprogressview.StartAnimation(sender);
				addprogressview.Hidden = false;
				addpopover.Behavior = NSPopoverBehavior.Transient;
				return;
			}
			// Set Values to pass
			string status = addpopoverstatus.Title;
			string episode = addpopoverepifield.StringValue;
			int score = (int)addpopoverscore.SelectedTag;
			addtitlebutton.Enabled = false;
			Thread t = new Thread(() => addtitlepopover(selectedaddtitleid, episode, status, score)); ;
			t.Start();
		}
		private void addtitlepopover(int id, string epi, string status, int score)
		{
			IRestResponse response = malengine.addtitle(id, epi, status, score);
			if (response.StatusCode.GetHashCode() == 201)
			{
				// Refresh List
				performloadlist(true);
				InvokeOnMainThread(() =>
				{
					// UI
					addprogressview.Hidden = true;
					addtitlebutton.Enabled = true; 
					// Apply Filters
					filterlist();
					addpopover.Behavior = NSPopoverBehavior.Transient;
					addpopover.Close();
				});
			}
			else
			{
				InvokeOnMainThread(() =>
				{
					// Apply Filters
					addprogressview.Hidden = true; 
					addtitlebutton.Enabled = true; 
					addpopover.Behavior = NSPopoverBehavior.Transient;
				});
			}
		}
		partial void removetitle(Foundation.NSObject sender)
		{
			NSDictionary d = (NSDictionary)animelistarraycontroller.SelectedObjects[0];
			NSNumber idnum = (NSNumber)d.ValueForKey(new NSString("id"));
			string title = (NSString)d.ValueForKey(new NSString("title")).ToString();
			NSAlert a = new NSAlert();
			a.AddButton("Yes");
			a.AddButton("No");
			a.MessageText = "Do you want to remove title " + title;
			a.InformativeText = "Once done, this cannot be undone.";
			a.AlertStyle = NSAlertStyle.Informational;
			long choice = a.RunSheetModal(w);
			if (choice == (long)NSAlertButtonReturn.First)
			{
				Thread t = new Thread(() => performremovetitle(idnum.Int32Value));
				t.Start();
			}
		}
		private void performremovetitle(int id)
		{
			IRestResponse response = malengine.deletetitle(id);
			if (response.StatusCode.GetHashCode() != 200)
			{
				InvokeOnMainThread(() =>
				{
					NSAlert a = new NSAlert();
					a.MessageText = "Can't remove title.";
					a.InformativeText = "Please try again later.";
					a.AlertStyle = NSAlertStyle.Critical;
				});
			}
			else
			{
				InvokeOnMainThread(() =>
				{
					performloadlist(true);
				});
			}
		}
		partial void edittitle(Foundation.NSObject sender)
		{
			// Shows edit popup;
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					showminieditpopup((NSDictionary)animelistarraycontroller.SelectedObjects[0],sender);
					return;
				case "Title Info":
					showminieditpopup(retrievetitlerecordfromlist(aniinfoid),sender);
					break;
			}
		}
		partial void viewonmal(Foundation.NSObject sender)
		{
			// Opens the anime title's page on MyAnimeList
			NSUrl link = new NSUrl("https://myanimelist.net/anime/" + aniinfoid);
			NSWorkspace.SharedWorkspace.OpenUrl(link);
		}
		// Anime List View
		public void performloadlist(bool refresh)
		{
			var account = Keychain.retrieveaccount();
			string username = account.Account;
			Thread t = new Thread(() => loadlist(refresh, username));
			t.Start();
		}
		public void loadlist(bool refresh, string username)
		{
			string content = malengine.loadanimeList(username, refresh);
			if (content.Length > 0)
			{
				InvokeOnMainThread(() =>
				{
					loggedinuser.StringValue = "Logged in as " + username;
					// Populate data in list view
					populateanimelist(content);
				});
			}
		}
		private void populateanimelist(string content)
		{
			// Populates list data from JSON
			NSMutableArray a = (NSMutableArray)animelistarraycontroller.Content;
			a.RemoveAllObjects();
			// Deserialize JSON
			NSData data = NSData.FromString(content);
			NSError e;
			NSDictionary adata = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
			NSArray alist = (NSArray)adata.ValueForKey((NSString)"anime");
			// Populate counts for status filters
			countstatus(alist);
			// Populate Table View
			animelistarraycontroller.AddObjects(alist);
			animetb.ReloadData();
			animetb.DeselectAll(Self);
			//Filter List
			filterlist();
		}
		public void clearanimelist()
		{
			//When user is logged out
			NSMutableArray a = (NSMutableArray)animelistarraycontroller.Content;
			a.RemoveAllObjects();
			loggedinuser.StringValue = "Not logged in";
			var selected = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			if (selected.Title == "Anime List")
			{
				loadmainview();
			}
		}
		private void filterlist()
		{
			string finalpredicate = "";
			List<string> predicates = new List<string>();
			if (Filter.StringValue.Length > 0)
			{
				predicates.Add("(title CONTAINS[cd] %@)");

			}
			List<string> statuses = new List<string>();
			for (int i = 0; i < 5; i++)
			{
				string status = "";
				int state = 0;
				switch (i)
				{
					case 0:
						status = "watching";
						state = filterwatching.State.GetHashCode();
						break;
					case 1:
						status = "completed";
						state = filtercompleted.State.GetHashCode();
						break;
					case 2:
						status = "on-hold";
						state = filteronhold.State.GetHashCode();
						break;
					case 3:
						status = "dropped";
						state = filterdropped.State.GetHashCode();
						break;
					case 4:
						status = "plan to watch";
						state = filterplantowatch.State.GetHashCode();
						break;
				}
				if (state == 1)
				{
					statuses.Add(status);
				}
			}
			List<NSObject> objects = new List<NSObject>();
			if (predicates.Count + statuses.Count > 0)
			{
				if (Filter.StringValue.Length > 0)
				{
					objects.Add((NSString)Filter.StringValue);
					finalpredicate = predicates[0];
				}
				for (int i = 0; i < statuses.Count; i++)
				{
					objects.Add((NSString)statuses[i]);
					predicates.Add((NSString)"watched_status ==[c] %@");
				}
				for (int i = 0; i < predicates.Count; i++)
				{
					if (Filter.StringValue.Length > 0 && i == 0)
					{
						if (i == 0)
						{
							finalpredicate = finalpredicate + " AND (" + predicates[i + 1];
						}
						else if (i < predicates.Count - 1)
						{
							finalpredicate = finalpredicate + " OR " + predicates[i + 1];
						}
						else
						{
							finalpredicate = finalpredicate + " OR " + predicates[i + 1] + ")";
						}
					}
					else
					{
						if (i == 0)
						{
							finalpredicate = predicates[i];
						}
						else
						{
							finalpredicate = finalpredicate + " OR " + predicates[i];
						}
					}
				}
				NSPredicate predicate = NSPredicate.FromFormat(finalpredicate, objects.ToArray());
				animelistarraycontroller.FilterPredicate = predicate;
			}
			else
			{
				NSPredicate predicate = NSPredicate.FromFormat((NSString)"watch_status == %@", (NSString)"none");
				animelistarraycontroller.FilterPredicate = predicate;
			}
		}
		partial void performstatusfilter(Foundation.NSObject sender)
		{
			filterlist();

		}
		private void countstatus(NSArray a)
		{
			int watching = countstatus(a, "watching");
			int completed = countstatus(a, "completed");
			int onhold = countstatus(a, "on-hold");
			int plantowatch = countstatus(a, "plan to watch");
			int dropped = countstatus(a, "dropped");
			// add item counts to filter buttons
			filterwatching.Title = "Watching (" + watching + ")";
			filtercompleted.Title = "Completed (" + completed + ")";
			filteronhold.Title = "On-hold (" + onhold + ")";
			filterdropped.Title = "Dropped (" + dropped + ")";
			filterplantowatch.Title = "Plan to watch (" + plantowatch + ")";
		}
		private int countstatus(NSArray a, string status)
		{
			NSObject[] objects = new NSObject[1];
			string filterfield = "(watched_status ==[c] %@)";
			objects[0] = (NSString)status;
			NSPredicate predicate = NSPredicate.FromFormat(filterfield, objects);
			a = a.Filter(predicate);
			return (int)a.Count;
		}
		partial void animelistdoubleclick(Foundation.NSObject sender)
		{
			if (animetb.ClickedRow >= 0)
			{
				if ((int)animelistarraycontroller.SelectionIndex >= -1)
				{
					NSString animelistaction = (NSString)NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"doubeclickaction").ToString();
					switch (animelistaction)
					{
						case "Do Nothing":
							break;
						case "View Anime Info":
							// Loads Anime Information
							listtableclick();
							break;
						case "Modify Title":
							showminieditpopup((NSDictionary)animelistarraycontroller.SelectedObjects[0], sender);
							break;
					}
				}
			}
		}
		private void showminieditpopup(NSDictionary d, NSObject sender)
		{
			NSNumber id = (NSNumber)d.ValueForKey((NSString)"id");
			minipopupeepi.StringValue = (NSString)d.ValueForKey((NSString)"watched_episodes").ToString();
			NSNumber episodes = (NSNumber)d.ValueForKey((NSString)"episodes");
			if (episodes.Int16Value > 0)
			{
				minipopupepiformat.Maximum = episodes;
			}
			else
			{
				minipopupepiformat.Maximum = null;
			}
			string airstatus = (NSString)d.ValueForKey((NSString)"status").ToString();
			if (airstatus == "finished airing")
			{
				selectedlistairing = false;
			}
			else
			{
				selectedlistairing = true;
			}
			minipopuptotalepi.StringValue = episodes.ToString();
			minipopupstatus.Title = (NSString)d.ValueForKey((NSString)"watched_status").ToString();
			NSNumber score = (NSNumber)d.ValueForKey((NSString)"score");
			minipopupscore.SelectItemWithTag(score.NIntValue);
			selectedlisteditid = id.Int32Value;
			minipopupprogressindicatoor.Hidden = true;
			minipopupeditstatus.Hidden = true;
			var selecteditem = (SourceListItem)sourcelist.ItemAtRow(sourcelist.SelectedRow);
			switch (selecteditem.Title)
			{
				case "Anime List":
					minieditpopover.Show(animetb.GetCellFrame(0, animetb.SelectedRow), animetb, 0);
					return;
				case "Title Info":
					NSButton btn = (NSButton)sender;
					minieditpopover.Show(btn.Bounds, btn, NSRectEdge.MaxYEdge);
					break;
			}

		}
		public void listtableclick()
		{
			NSDictionary d = (NSDictionary)animelistarraycontroller.SelectedObjects[0];
			NSNumber idnum = (NSNumber)d.ValueForKey(new NSString("id"));

			Thread t = new Thread((obj) => loadAnimeInfo(idnum.Int32Value));
			t.Start();
		}
		partial void performeditminipopover(Foundation.NSObject sender)
		{
			// Set UI
			minipopupeditstatus.StringValue = "";
			minipopupprogressindicatoor.StartAnimation(sender);
			minipopupprogressindicatoor.Hidden = false;
			minieditpopover.Behavior = NSPopoverBehavior.ApplicationDefined;
			// Validate update data
			if (minipopupeepi.StringValue == minipopuptotalepi.StringValue && minipopuptotalepi.StringValue != "0" && minipopupstatus.Title != "completed")
			{
				minipopupstatus.Title = "completed";
			}
			if (selectedlistairing == true && minipopupstatus.Title == "completed")
			{
				//Invalid
				minipopupeditstatus.StringValue = "Invalid Update..";
				minipopupprogressindicatoor.StartAnimation(sender);
				minipopupprogressindicatoor.Hidden = false;
				minieditpopover.Behavior = NSPopoverBehavior.Transient;
				return;
			}
			// Set Values to pass
			string status = minipopupstatus.Title;
			string episode = minipopupeepi.StringValue;
			int score = (int)minipopupscore.SelectedTag;
			minieditpopoveredit.Enabled = false;
			Thread t = new Thread(() => editminipopover(selectedlisteditid, episode, status, score)); ;
			t.Start();

		}
		partial void minieditstatuschanged(Foundation.NSObject sender){
			if (minipopupeepi.StringValue != "0" && minipopupstatus.Title == "completed")
			{
				minipopupeepi.StringValue = minipopuptotalepi.StringValue;
			}
		}
		private void editminipopover(int id, string epi, string status, int score)
		{
			IRestResponse response = malengine.updatetitle(id,epi,status,score);
			if (response.StatusCode.GetHashCode() == 200)
			{
				// Refresh List
				performloadlist(true);
				InvokeOnMainThread(() =>
				{
					// UI
					minipopupprogressindicatoor.Hidden = true;
					minipopupeditstatus.Hidden = true;
					minieditpopoveredit.Enabled = true;
					// Apply Filters
					filterlist();
					minieditpopover.Behavior = NSPopoverBehavior.Transient;
					minieditpopover.Close();
				});
			}
			else
			{
				InvokeOnMainThread(() =>
				{
					// Apply Filters
					minipopupprogressindicatoor.Hidden = true;
					minipopupeditstatus.Hidden = false;
					minieditpopoveredit.Enabled = true;
					minipopupeditstatus.StringValue = "Update failed.";
					minieditpopover.Behavior = NSPopoverBehavior.Transient;
				});
			}
		}
		// Searchview
		partial void performsearch(Foundation.NSObject sender)
		{
			// Performs Search
			string term = searchbox.StringValue;
			// Create Thread
			Thread thread = new Thread(() => performsearch(term));
			// Perform Search
			thread.Start();
		}
		private void performsearch(string term)
		{
			IRestResponse response = malengine.search(term);
			if (response.StatusCode.GetHashCode() == 200)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					loadsearchdata(response.Content);
				});
			}
		}

		private void loadsearchdata(String content)
		{
			// Populates search data from JSON
			NSMutableArray a = (NSMutableArray)searcharraycontroller.Content;
			a.RemoveAllObjects();
			// Deserialize JSON
			NSData data = NSData.FromString(content);
			NSError e;
			NSArray searchdata = (NSArray)NSJsonSerialization.Deserialize(data, 0, out e);
			// Populate Table View
			searcharraycontroller.AddObjects(searchdata);
			stb.ReloadData();
			stb.DeselectAll(Self);
		}
		partial void searchtbdoubleclick(Foundation.NSObject sender)
		{
			if (stb.ClickedRow >= 0)
			{
				if ((int)searcharraycontroller.SelectionIndex >= -1)
				{
					// Loads Anime Information
					searchtableclick();
				}
			}
		}
		public void searchtableclick()
		{
			NSDictionary d = (NSDictionary)searcharraycontroller.SelectedObjects[0];
			NSNumber idnum = (NSNumber)d.ValueForKey(new NSString("id"));

			Thread t = new Thread((obj) => loadAnimeInfo(idnum.Int32Value));
			t.Start();
		}
		// Anime Information View
		private void loadAnimeInfo(int id)
		{
			// Change page to Anime Info
			int tmpid = aniinfoid;
			aniinfoid = 0;
			InvokeOnMainThread(() =>
				{
					// Change Source List selection to Anime Info
					sourcelist.SelectRow(4,false);
					noinfo.Hidden = true;
					loadingwheel.Hidden = false;
					loadingwheel.StartAnimation(null);
				});
			IRestResponse response = malengine.loadanimeinfo(id);
			if (response.StatusCode.GetHashCode() == 200)
			{
				// Deserialize data
				NSData data = NSData.FromString(response.Content);
				NSError e;
				NSDictionary animedata = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
				currentaniinfo = animedata;
				InvokeOnMainThread(() =>
				{
					populateanimeinfo(id, animedata);
				});
			}
			else {
				aniinfoid = tmpid;
				InvokeOnMainThread(() =>
				{
					loadingwheel.StopAnimation(null);
					loadmainview();
				});
			}
		}

		private void populateanimeinfo(int id, NSDictionary animedata)
		{
			// Populate Anime Information
			animeinfotitle.StringValue = (NSString)animedata.ValueForKey(new NSString("title")).ToString();
			alternativetitlelbl.StringValue = generatetitleslist(animedata);
			NSImage img = SupportFiles.retrieveImage((NSString)animedata.ValueForKey(new NSString("image_url")),id);
			posterimage.Image = img;
			NSNumber rank = (NSNumber)animedata.ValueForKey(new NSString("rank"));
			NSNumber popularityrank = (NSNumber)animedata.ValueForKey(new NSString("popularity_rank"));
			string type = (NSString)animedata.ValueForKey(new NSString("type")).ToString();
			NSNumber episodes = (NSNumber)animedata.ValueForKey(new NSString("episodes"));
			string status = (NSString)animedata.ValueForKey(new NSString("status")).ToString();
			NSNumber duration = (NSNumber)animedata.ValueForKey(new NSString("duration"));
			string classification = (NSString)animedata.ValueForKey(new NSString("classification")).ToString();
			NSNumber memberscore = (NSNumber)animedata.ValueForKey(new NSString("members_score"));
			NSNumber memberscount = (NSNumber)animedata.ValueForKey(new NSString("members_count"));
			NSArray genrelist = (NSArray)animedata.ValueForKey(new NSString("genres"));
			string genres = "None";
			//Populate Genres
			if (genrelist != null){
				for (nuint i = 0; i <  genrelist.Count; i++)
				{
					if (i == 0)
					{
						genres = genrelist.GetItem<NSString>(i).ToString();
					}
					else {
						genres = genres + ", " + genrelist.GetItem<NSString>(i).ToString();
					}
				}
			}
			NSNumber favoritedcount = (NSNumber)animedata.ValueForKey(new NSString("favorited_count"));
			string detail = "Type: " + type + Environment.NewLine;
			if (episodes == null)
			{
				if (duration == null)
				{
					detail = detail + "Episodes: Unknown" + Environment.NewLine;

				}
				else {
					detail = detail + "Episodes: Unknown (" + duration.Int32Value + " mins long per episode)" + Environment.NewLine;
				}
			}
			else {
				if (duration == null)
				{
					detail = detail + "Episodes: " + episodes.Int32Value + Environment.NewLine;

				}
				else {
					detail = detail + "Episodes: " + episodes.Int32Value + " (" + duration.Int32Value + " mins long per episode)" + Environment.NewLine;

				}
			}
			detail = detail + "Status: " + status + Environment.NewLine;
			detail = detail + "Genres: " + genres + Environment.NewLine;
			detail = detail + "Classification: " + classification + Environment.NewLine;
			if (memberscore != null)
			{
				detail = detail + "Score: " + memberscore.FloatValue + " (" + memberscount.Int32Value + " users, ranked " + rank.Int32Value + ")" + Environment.NewLine;
			}
			detail = detail + "Popularity: " + popularityrank.Int32Value + Environment.NewLine;
			detail = detail + "Favorites: " + favoritedcount.Int32Value;
			detailstextview.Value = detail;
			if (animedata.ValueForKey(new NSString("background")) != null)
			{
				backgroundtextview.Value = StripHTML((NSString)animedata.ValueForKey(new NSString("background")).ToString());
			}
			else {
				backgroundtextview.Value = "None available.";
			}
			synopsistextview.Value = StripHTML((NSString)animedata.ValueForKey(new NSString("synopsis")).ToString());
			loadingwheel.StopAnimation(null);
			aniinfoid = id;
			// Save current data
			currentaniinfo = animedata;
			loadmainview();
		}
		private string generatetitleslist(NSDictionary d)
		{
			NSMutableArray a = new NSMutableArray();
			NSDictionary titles = (NSDictionary)d.ValueForKey(new NSString("other_titles"));
			for (int i = 0; i < 3; i++)
			{
				NSArray titleslist = new NSArray();
				switch (i)
				{
					
					case 0:
						if ((NSArray)titles.ValueForKey(new NSString("english")) != null)
						{
							titleslist = (NSArray)titles.ValueForKey(new NSString("english"));
						}
						break;
					case 1:
						if ((NSArray)titles.ValueForKey(new NSString("japanese")) != null)
						{
							titleslist = (NSArray)titles.ValueForKey(new NSString("japanese"));
						}
						break;
					case 2:
						if ((NSArray)titles.ValueForKey(new NSString("synonyms")) != null)
						{
							titleslist = (NSArray)titles.ValueForKey(new NSString("synonyms"));
						}
						break;
				}

				for (nuint s = 0; s < titleslist.Count; s++){
					a.Add(titleslist.GetItem<NSString>(s));
				}
			}
			string strtitles = "";
			for (nuint i = 0; i < a.Count; i++)
			{
				if (i == 0)
				{
					strtitles = (NSString)a.GetItem<NSString>(i).ToString();
				}
				else {
					strtitles = strtitles + ", " + (NSString)a.GetItem<NSString>(i).ToString();
				}
			}
			return strtitles;
		}
		// Season View
		private void performseasondatarefresh()
		{
			// Create Thread
			Thread thread = new Thread(new ThreadStart(refreshseasondata));
			// Perform Search
			thread.Start();
		}
		private void refreshseasondata()
		{
			string content = SupportFiles.retrieveSeasonIndex(true);
			if (content.Length > 0)
			{
				bool success = SupportFiles.retrieveallseasondata(true);
				InvokeOnMainThread(() =>
				{
					// Refresh popup menus and populate season data
					retrieveseasonindex(false);
				});
			}
		}
		private void performseasonindexretrieval()
		{
			// Create Thread
			Thread thread = new Thread(() => retrieveseasonindex(false));
			// Perform Search
			thread.Start();
		}
		private void retrieveseasonindex(bool refreshindex)
		{
			// Retrieves Season Data 
			string content = SupportFiles.retrieveSeasonIndex(refreshindex);
			if (content.Length > 0)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					populateyearpopup(content);
					seasonyrselect.SelectItem(seasonyrselect.ItemCount - 1); //Select current year;
					populateseasonpopup((nuint)seasonyrselect.IndexOfSelectedItem);
					if (seasonselect.ItemCount - 1 >= 0)
					{
						seasonselect.SelectItem(seasonselect.ItemCount - 1); //Select most recent season, only if it has more than two seasons;
					}
					performseasondata();
				});
			}
			else
			{
				seasonyrselect.RemoveAllItems();
				seasonselect.RemoveAllItems();
			}
		}
		private void populateyearpopup(string content)
		{
			seasonyrselect.RemoveAllItems();
			if (seasonindex != null)
			{
				seasonindex = new NSArray();
			}
			// Deserialize JSON
			NSData data = NSData.FromString(content);
			NSError e;
			NSDictionary d = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
			seasonindex = (NSArray)d.ValueForKey(new NSString("years"));
			for (int i = 0; i < (int)seasonindex.Count; i++)
			{
				NSDictionary yr = seasonindex.GetItem<NSDictionary>((nuint)i);
				seasonyrselect.AddItem((NSString)yr.ValueForKey(new NSString("year")).ToString());
			}
		}
		private void populateseasonpopup(nuint selected)
		{
			seasonselect.RemoveAllItems();
			NSDictionary d = seasonindex.GetItem<NSDictionary>(selected);
			NSArray seasons = (NSArray)d.ValueForKey(new NSString("seasons"));
			for (nuint i = 0; i < seasons.Count; i++)
			{
				NSDictionary s = seasons.GetItem<NSDictionary>(i);
				seasonselect.AddItem((NSString)s.ValueForKey(new NSString("season")).ToString());
			}
		}
		partial void yearchanged(Foundation.NSObject sender)
		{
			populateseasonpopup((nuint)seasonyrselect.IndexOfSelectedItem);
			performseasondata();
		}
		partial void seasonchanged(Foundation.NSObject sender)
		{
			performseasondata();
		}
		private void performseasondata()
		{
			// Retrieve JSON Season URL
			NSDictionary d = seasonindex.GetItem<NSDictionary>((nuint)seasonyrselect.IndexOfSelectedItem);
			string year = d.ValueForKey((NSString)"year").ToString();
			NSArray a1 = (NSArray)d.ValueForKey((NSString)"seasons");
			d = a1.GetItem<NSDictionary>((nuint)seasonselect.IndexOfSelectedItem);
			string season = d.ValueForKey((NSString)"season").ToString();
			// Create Thread
			Thread thread = new Thread(() => loadseasondata(season,year));
			// Perform Search
			thread.Start();
		}
		private void loadseasondata(string season, string year)
		{
			// Retrieves Season Data 
			string content = SupportFiles.retrievedataforyrseason(year, season, false);
			if (content.Length > 0)
			{
				InvokeOnMainThread(() =>
				{
					// Populate data in Search Table View
					performseasondatapop(content);
					});
			}
		}
		private void performseasondatapop(string Content)
		{
			// Populates search data from JSON
			NSMutableArray a = (NSMutableArray)seasonarraycontroller.Content;
			a.RemoveAllObjects();
			// Deserialize JSON
			NSData data = NSData.FromString(Content);
			NSError e;
			NSDictionary json = (NSDictionary)NSJsonSerialization.Deserialize(data, 0, out e);
			NSArray seasondataarray = (NSArray)json.ValueForKey((NSString)"anime");
			// Populate Table View
			seasonarraycontroller.AddObjects(seasondataarray);
			seasontb.ReloadData();
			seasontb.DeselectAll(Self);
		}

		partial void seasontbdoubleclicked(Foundation.NSObject sender)
		{
			NSDictionary d = (NSDictionary)seasonarraycontroller.SelectedObjects[0];
			d = (NSDictionary)d.ValueForKey((NSString)"id");

			Thread t = new Thread((obj) => loadAnimeInfo(Convert.ToInt32((NSString)d.ValueForKey((NSString)"id").ToString())));
			t.Start();
		}
		// Other
		public static string StripHTML(string input)
		{
			return Regex.Replace(input, "<.*?>", String.Empty);
		}
		public void performappearencechange()
		{
			string appearence = (NSString)NSUserDefaults.StandardUserDefaults.ValueForKey((NSString)"windowappearence").ToString();
			NSString appearencename = new NSString();
			switch (appearence)
			{
				case "Light":
					appearencename = NSAppearance.NameVibrantLight;
					break;
				case "Dark":
					appearencename = NSAppearance.NameVibrantDark;
					break;

			}
			w.Appearance = NSAppearance.GetAppearance(appearencename);
			progressview.Appearance = NSAppearance.GetAppearance(appearencename);
			animeinfoview.Appearance = NSAppearance.GetAppearance(appearencename);
			listloggedoutview.Appearance = NSAppearance.GetAppearance(appearencename);
			base.Window.SetFrame(base.Window.Frame, true);
		}
		partial void viewloginpref(Foundation.NSObject sender)
		{
			appdel.showloginprefs();
		}
		private bool checkiftitleexistsonlist(int id)
		{
			NSDictionary d = retrievetitlerecordfromlist(id);
			if (d != null)
			{
				return true;
			}
			return false;
		}
		private NSDictionary retrievetitlerecordfromlist(int id)
		{
			NSArray a = (NSArray)animelistarraycontroller.Content;
			NSObject[] objects = new NSObject[1];
			string filterfield = "(id ==[c] %@)";
			objects[0] = new NSNumber(id);
			NSPredicate predicate = NSPredicate.FromFormat(filterfield, objects);
			a = a.Filter(predicate);
			if (a.Count > 0)
			{
				return a.GetItem<NSDictionary>(0);
			}
			return null;
		}
		private void showneedaccountdialog()
		{
			//Notifies user if he or she uses a feature that requires credentials
			NSAlert a = new NSAlert();
			a.AddButton("Yes");
			a.AddButton("No");
			a.MessageText = "This functionality needs an account.";
			a.InformativeText = "To take advantage of this feature need to login. Do you want to open Preferences to log in now?" + Environment.NewLine + Environment.NewLine +
					"Note that you do not need to login to use the explore features.";
			a.AlertStyle = NSAlertStyle.Informational;
			long choice = a.RunSheetModal(w);
			if (choice == (long)NSAlertButtonReturn.First)
			{
				appdel.showloginprefs();
			}
		}
	}
}
