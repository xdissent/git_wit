module GitWit
  # Public: Determine the path to the authorized_keys file based on the 
  # configuration. If not explicitly configured, the ssh_user's home directory 
  # is used to construct the path by adding ".ssh/authorized_keys".
  #
  # Returns the path as a String or nothing if it cannot be determined.
  def self.authorized_keys_path
    return config.authorized_keys_path if config.authorized_keys_path.present?
    if ssh_user.present?
      File.expand_path(File.join("~#{ssh_user}", ".ssh", "authorized_keys"))
    end
  end

  # Public: Get an authorized_keys file instance.
  #
  # Returns an AuthorizedKeys::File instance.
  # Raises ConfigurationError if the path cannot be determined.
  def self.authorized_keys_file
    path = authorized_keys_path
    return AuthorizedKeys::File.new path if path.present?
    raise ConfigurationError "Could not determine path to authorized_keys file"
  end

  # Public: Clear out all existing public keys in the authorized_keys file and
  # add each public key for each user in the key map to the new file.
  #
  # keys_map - The Hash of String public key contents, keyed by String username.
  #
  # Returns nothing.
  def self.regenerate_authorized_keys(keys_map)
    authorized_keys_file.clear do |file|
      keys_map.each do |username, keys|
        keys.each do |key|
          file.add AuthorizedKeys::Key.shell_key_for_username(username, key)
        end
      end
    end
    nil
  end

  # Public: Add a public key for a given username to the authorized_keys file.
  #
  # username - The String username for the public key owner.
  # key      - The String public key contents.
  #
  # Returns nothing.
  def self.add_authorized_key(username, key)
    authorized_keys_file.add AuthorizedKeys::Key.shell_key_for_username(username, key)
  end

  # Public: Remove a public key from the authorized_keys file.
  #
  # key - The String public key contents.
  #
  # Returns nothing.
  def self.remove_authorized_key(key)
    authorized_keys_file.remove key
  end
end
