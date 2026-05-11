require 'rubygems'
require 'gosu'
require './input_functions'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
	BACKGROUND, PLAYER, UI = *0..2
end

module Genre
	POP, CLASSIC, JAZZ, ROCK = *1..4
end

$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

class Album
    attr_accessor :artist, :title, :label, :genre, :artwork, :tracks

    def initialize (artist, title, label, genre, artwork, tracks)
        @artist = artist
        @title = title
        @genre = genre 
        @label = label
        @artwork = artwork
        @tracks = tracks
    end
end

class Track
	attr_accessor :name, :location, :duration

	def initialize (name, location, duration)
		@name = name
		@location = location
        @duration = duration
	end
end




class MusicPlayerMain < Gosu::Window

	def initialize
	    super 800, 600
	    self.caption = "Music Player"

		# Reads in an array of albums from a file
		# Stores the albums array as an instance variable for method access.
		music_file = File.new("albums.txt", "r")
		albums = read_albums(music_file)
		@albums = albums

		# Default coordinates for Track text
		@text_x = 550
		@text_y = 30

		# Empty array for the album coordinates to be added to
		@album_coordinates = []
		# Empty array for the tracks of a 'clicked' album
		@gosu_tracks = []
		# Empty string for the clicked track
		@gosu_track = ""
		# Empty array for a clicked album to be added into
		@gosu_album = []

		# Initialising fonts
		@track_font = Gosu::Font.new(30)
		@font_colour = Gosu::Color::BLACK
		@nowPlaying = Gosu::Font.new(30)
		@defaultText = "Gosu Music Player"		
	end


  	# Returns an array of tracks read from the given file
	def read_tracks(music_file)
		count = music_file.gets().to_i()
		tracks = Array.new()

		index = 0
		while index < count
			track = read_track(music_file)
			tracks << track
			index += 1
		end
		return tracks
	end

	# Reads in and returns a single track from the given file
	def read_track(music_file)
		track_name = music_file.gets()
		track_location = music_file.gets().chomp
		track_duration = music_file.gets()
		track = Track.new(track_name, track_location, track_duration)
		return track
	end

	# Takes an array of tracks and prints them to the terminal. Not used in GUI
	def print_tracks(tracks)
		index = 0
		while index < tracks.length
			track = tracks[index]
			# Displays a track number for each track. 'Primary key'
			puts ("#{index + 1}:")
			print_track(track)
			index += 1
		end
	end

	# Takes a single track and prints it to the terminal. Not used in GUI
	def print_track(track)
		puts ("Track: #{track.name}")
		puts ("Location: #{track.location}\n")
		puts ("Duration: #{track.duration} \n")
	end

	# Returns an array of albums read from the given file
	def read_albums(music_file)
		count = music_file.gets.to_i
		albums = Array.new()

		index = 0
		while index < count
			album = read_album(music_file)
			albums << album
			index += 1
		end
		return albums
	end


	# Reads in and returns a single album from the given file, with all its tracks
	def read_album(music_file)
		album_artist = music_file.gets
		album_title = music_file.gets
		album_label = music_file.gets
		album_genre = music_file.gets.to_i
		artwork_file = music_file.gets.chomp
		album_artwork = ArtWork.new(artwork_file)
		album_tracks = read_tracks(music_file)
		
		album = Album.new(album_artist, album_title, album_label, album_genre, album_artwork, album_tracks)
		return album
	end

	# Takes an array of albums and prints them to the terminal. Not used in GUI
	def print_albums(albums)
		index = 0
		while index < albums.length
			album = albums[index]
			# Displays an album number for each album. 'Primary key'
			puts("#{index + 1}:")
			print_album(album)
			index += 1
		end
	end


	# Takes a single album and prints it to the terminal along with all its tracks. Not used in GUI
	def print_album(album)
		puts("Artist: #{album.artist}")
		puts("Album: #{album.title}")
		puts("Label: #{album.label}")
		puts("Genre: #{$genre_names[album.genre]}\n\n")
	end
	
  

	# Draws the artwork on the screen for all the albums
	def draw_albums(albums)
		x_position = 5 # default x position for first album
		y_position = 5 # default y position for first album
		index = 0
		while index < albums.length
			album = albums[index]
			# Accesses Artwork @bmp attribute to draw the image
			album.artwork.bmp.draw(x_position, y_position, ZOrder::PLAYER) 
			image_width = album.artwork.bmp.width
			image_height = album.artwork.bmp.height

			# Adds album coordinate information to a new array, and appends this to the existing empty array.
			@album_coordinates << [
				x_position, #leftX
				y_position, #topY
				x_position + image_width, #rightX
				y_position + image_height, #bottomY
				album
			]
			
			# Adds album with (plus padding) to the X position 
			x_position += (image_width + 5) 

			# Rows will only be 2 'album widths' wide
			if x_position > (image_width * 2) 
				# Resets x position to default, and increases y position by the image height
				x_position = 5
				y_position += (image_height + 5)
			end
			
			index += 1
		end
	end

	

	# Detects if a 'mouse sensitive' area has been clicked on
	# i.e either an album or a track. returns true or false
	def area_clicked(leftX, topY, rightX, bottomY)
		if mouse_x >= leftX && mouse_x <= rightX && mouse_y >= topY && mouse_y <= bottomY
			return true
    	else
			return false
		end
	end

	# Returns album array if clicked, returns nil if nothing is clicked
	def album_clicked?
		index = 0
		while index < @album_coordinates.length
			coordinates = @album_coordinates[index]
			# gets coordinates from each album_coordinates array, and the 'album' for future reference. 
			leftX = coordinates[0]
			topY = coordinates[1]
			rightX = coordinates[2]
			bottomY = coordinates[3]
			album = coordinates[4]

			# passes coordinates to area_clicked function
			if area_clicked(leftX, topY, rightX, bottomY)
				return album
			end
			index += 1
		end
		nil 
	end

	# Returns track if clicked, returns nil if nothing is clicked
	def track_clicked?(tracks)
		index = 0
		while index < tracks.length
			track = tracks[index]

			# Uses the height and width of each drawn font to determine the clicked area
			text_width = @track_font.text_width(track.name)
			text_height = @track_font.height

			leftX = @text_x
			topY = 30 + (index * 50)
			rightX = leftX + text_width
			bottomY = topY + text_height

			if area_clicked(leftX, topY, rightX, bottomY)
				return track  
			end
			index += 1
		end
		nil 
	end



	# Uses the tracks array passed through via the clicked album
	# If album is not clicked on, (if tracks array is empty), Default message will print.
	def display_track(tracks)
		index = 0
		if tracks.length > 0
			while index < tracks.length
				title = tracks[index].name
				@track_font.draw_text(title, @text_x, @text_y, ZOrder::PLAYER, 1.0, 1.0, @font_colour)
				@text_y += 50
				index += 1
			end
			@text_y = 30
		else
			@track_font.draw_text("Select an album", @text_x, @text_y, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		end
	end



	# Takes a track index and an Album and plays the Track from the Album
	def playTrack(track)
		@song = Gosu::Song.new(track.location)
		@song.play(false)
	end

	# Displays now playing message.
	def nowPlaying(track, album)
		# Track empty?
		if track != "" 
			title = "Now playing #{track.name}"
			@nowPlaying.draw_text(title, 20, 530, ZOrder::PLAYER, 1.0, 1.0, @font_colour)

		# Album array empty?
		elsif album != []
			title = "#{album.artist}#{album.title}"
			@nowPlaying.draw_text(title, 20, 530, ZOrder::PLAYER, 1.0, 1.0, @font_colour)

		else
			title = @defaultText #default text
			@nowPlaying.draw_text(title, 20, 530, ZOrder::PLAYER, 1.0, 1.0, @font_colour)
		end
	end

	# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
	def draw_background
		draw_quad(0, 0, TOP_COLOR, 800, 0, TOP_COLOR, 800, 600, BOTTOM_COLOR, 0, 600, BOTTOM_COLOR, ZOrder::BACKGROUND)
	end


	def update
		if button_down?(Gosu::MsLeft)
			# album record is clicked album
			if album = album_clicked?
				@gosu_tracks = album.tracks
				@gosu_album = album
			else 
				# If album is not clicked, array is empty again
				@gosu_album = []
			end

			
			if track = track_clicked?(@gosu_tracks)
				# Updates @gosu_track to the selected track. sends to draw
				@gosu_track = track 
				playTrack(@gosu_track)
			else 
				# If track is not clicked, @gosu_tracks is now empty. 
				@gosu_track = ""
			end

		end
	end

 	# Draws the album images and the track list for the selected album. 
	# Also draws the nowPlaying message, which changes if an album or track is clicked. 
	def draw
		draw_background
		draw_albums(@albums)
		display_track(@gosu_tracks)
		nowPlaying(@gosu_track, @gosu_album)
	end

 	def needs_cursor?; true; end

	# not used
	def mouse_over_background(mouse_x, mouse_y) 
		leftX = 0
		topY = 0
		rightX = 800
		bottomY = 600
		if area_clicked(leftX, topY, rightX, bottomY)
			return true
		else
			return false
		end
	end



	# when to use this over update? Not used, but could have been used. 
	def button_down(id)
		case id
		when Gosu::MsLeft
		end
	end
end



MusicPlayerMain.new.show if __FILE__ == $0
