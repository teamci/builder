package mypkg

import "os/user"

// World returns a string World.
func World() string {
	user, err := user.Current()

	if err != nil {
		return ErrWorld("Could not get current user!").Error()
	}

	return user.Username
}
