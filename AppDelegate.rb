#
#  AppDelegate.rb
#  Scriptorium
#
#  Created by Patrick Thomson on 11/11/08.
#  Copyright (c) 2008 Patrick Thomson. All rights reserved.
#

require 'hotcocoa'

include HotCocoa

class AppDelegate
  
  attr_accessor :text_display_field
  
  # This mixture of camelCase and underscores is confusing me.
  # I tend to prefer underscores for Ruby.
  def validateToolbarItem(item)
    case item.label
    when "Open App Bundle"
      true
    when "Save Header Files"
      @temporary_directory
    end
  end
  
  def openAppBundle(sender)
    panel = NSOpenPanel.openPanel
    panel.allowsMultipleSelection = false
    panel.runModalForDirectory "~/Applications", :file => nil, :types => ["app"]
    generateHeadersForApplication(panel.filenames[0])
  end
  
  def generateHeadersForApplication(app)
    @app_name = app.lastPathComponent.sub('.app', '')
    @temporary_directory ||= NSTemporaryDirectory()
    # Backticks, I love you. At least compared to getting NSPipes and NSTasks to play nice.
    `sdef #{app} | sdp -fh --basename #{@app_name} -o #{@temporary_directory}`
    header_file_name = @temporary_directory + @app_name + '.h'
    @contents = NSString.stringWithContentsOfFile(header_file_name, :encoding => NSUTF8StringEncoding, :error => nil)
    @text_display_field.textStorage.attributedString = 
      NSAttributedString.alloc.initWithString(@contents, :attributes => {NSFontAttributeName => NSFont.fontWithName("Courier New", :size => 12)})
  end
  
  def saveHeaderFiles(sender)
    panel = NSSavePanel.savePanel
    panel.message = "Please choose a location to hold the header file."
    panel.canCreateDirectories = true
    panel.title = "Save .h file"
    panel.runModalForDirectory(nil, :file => @app_name + '.h')
    @contents.writeToFile(panel.filename, :atomically => true, :encoding => NSUTF8StringEncoding, :error => nil);
  end
end
