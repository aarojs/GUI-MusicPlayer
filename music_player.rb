# this is the final copy submitted to Ed. CREDIT LEVEL

require './input_functions'


module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end

$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

# Loops through genre array, can be called to print genres.
def print_genre
    index = 1
    while index < $genre_names.length
        puts("#{index.to_s} #{$genre_names[index]}")
        index += 1
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
	track_location = music_file.gets()
    track_duration = music_file.gets()
	track = Track.new(track_name, track_location, track_duration)
	return track
end

# Takes an array of tracks and prints them to the terminal
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

# Takes a single track and prints it to the terminal
def print_track(track)
    puts ("Track: #{track.name}")
    puts ("Location: #{track.location}")
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
    album_artwork = music_file.gets
    album_tracks = read_tracks(music_file)
    
    album = Album.new(album_artist, album_title, album_label, album_genre, album_artwork, album_tracks)
    return album
end

# Takes an array of albums and prints them to the terminal
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


# Takes a single album and prints it to the terminal along with all its tracks
def print_album(album)
    puts("Artist: #{album.artist}")
    puts("Album: #{album.title}")
    puts("Label: #{album.label}")
    puts("Genre: #{$genre_names[album.genre]}")
    puts("Artwork: #{album.artwork}\n")
end



# Main menu option 1
# Loads in the file to be read. Will return to Main Menu if file does not exist.
def load_albums
    file_name = read_string("You have selected Read in Albums, please enter the filename: ")
    result = File.exist?(file_name) 
      
    if result == true
        read_string("File loaded. \nPress Enter to continue.")
        music_file = File.new(file_name, "r")
        return music_file
    else
        read_string("File not found. Please try again. \nPress Enter to return to Main Menu.")
        # Returns to main menu 
        main 
    end
end




# Main menu option 2
def display_albums(albums)
    finished = false
    begin
        puts 'Display Albums Menu:'
        puts '1 Display All Albums'
        puts '2 Display Albums by Genre'
        puts '3 Return to Main Menu'
        choice = read_integer_in_range("Please enter your choice:", 1, 3)
        case choice
        when 1
          album_all(albums)  
        when 2
          album_genre(albums)  
        when 3
          finished = true
        else 
          puts "Please select again"
        end
    end until finished
end

# Display all albums
def album_all(albums)
    puts "\nAll albums: \n "
    print_albums(albums)
end

# Display all albums in a genre
def album_genre(albums)
    # Prints genres, and allows the user to select a genre.
    print_genre
    choice = read_integer_in_range("Please enter your choice (1-4): ", 1, 4)
    puts ("Searching for #{$genre_names[choice]} genre... \n\n")
    genre_searcher(albums, choice)
end

def genre_searcher(albums, choice)
    index = 0
    found = false

    while (index < albums.length)       
		if albums[index].genre == choice
            # Prints the album number, 'Primary key'
            puts("#{index + 1}:")
            album = albums[index]
            print_album(album)
			found = true
		end
		index += 1
	end
    if !found
        read_string("Genre #{$genre_names[choice]} not found. \nPress Enter to return to Menu.")
    end
end


# Main menu option 3
# Allows the user to select an album, and then display the tracks on the album, if there are any. 
def select_album(albums)
    # Allows a user to pick an album from the list. Uses albums.length as the maximum range
    choice = read_integer_in_range("Please select an Album from the list using the Album Number:  ", 1, albums.length)
    index = (choice - 1)
    # Uses user choice as the album index
    album = albums[index]
    puts "#{albums[index].artist}#{albums[index].title}"
    tracks = album.tracks
    print_tracks(tracks)

    # First checks if there are any tracks on the album.
    if tracks.length > 0
        track_choice = read_integer_in_range("Please select a track using the track number: ", 1, tracks.length)
        track_index = (track_choice - 1)

        # Uses the album index, but accesses the 'tracks' array via a new 'track_index'
        tracks = albums[index].tracks

        if track_index < tracks.length
            puts ("Playing #{tracks[track_index].name}from album #{albums[index].title}")
            sleep 3
        else
            puts "Please select a valid track number"
        end
    else
        read_string("There are no tracks on this album, press Enter to return to Menu. \n")
    end
end


# Main menu option 4
# New lines are used for consistent formatting. 
def add_albums(albums)
    title = ("#{read_string("Enter title: ")}\n")
    artist = ("#{read_string("Enter artist: ")}\n")
    label = ("#{read_string("Enter label: ")}\n")
    print_genre
    genre = read_integer_in_range("Enter number of genre: ", 1, 4)
    artwork = read_string("Enter the artwork: ")
    tracks = read_new_tracks

    new_album = Album.new(artist, title, label, artwork, genre, tracks)
    # Adds new album to the existing albums array
    albums << new_album
    read_string("Album added: #{title}Press Enter to continue.")
end

# Reads in new tracks from the user
def read_new_track
    track_name = ("#{read_string("Enter a name for the new track: ")}\n")
    location = ("#{read_string("Enter a location for the new track: ")}\n")
    duration = ("#{read_string("Enter the duration for the new track: ")}\n")
    new_track = Track.new(track_name, location, duration)
	return new_track
end

# Reads multiple new tracks
def read_new_tracks
    count = read_integer("Enter number of tracks: ")
    new_tracks = []
    index = 0
    while index < count
        new_track = read_new_track
        new_tracks << new_track
        index += 1
    end
    return new_tracks
end

# Main menu
def main
    finished = false
    begin
        puts 'Main Menu:'
        puts '1. Read in Albums'
        puts '2. Display Albums'
        puts '3. Select an Album to play'
        puts '4. Add an Album'
        puts '5. Exit the application'
        choice = read_integer_in_range("Please enter your choice:", 1, 5)
        case choice
        when 1
            music_file = load_albums
            file = true
            # Once file is read, read_albums can be called to access the albums array.
            albums = read_albums(music_file)
        when 2
            # Checks that a filename has been successfully entered before proceeding
            if file
                display_albums(albums)
                displayed = true
            else
                read_string("To Display Albums, first use Option 1 to enter a filename. \nPress Enter to return to Main Menu.")
            end
        when 3
            # File must be read, and albums must be first displayed before the user can select an album number
            if file & displayed       
                select_album(albums)
            else
                read_string("Use Option 2 to view available albums to play. \nPress Enter to return to Main Menu.")               
            end
        when 4
            # File must be read before user can add an album.
            if file
                add_albums(albums)
            else
                read_string("Please load an album file before adding an album. \nPress Enter to return to Main Menu.")
            end
        when 5
            finished = true
        else
            puts "Please select again"
        end
    end until finished
end
  

main
