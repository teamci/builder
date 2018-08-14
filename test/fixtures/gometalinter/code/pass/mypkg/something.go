package mypkg

// ErrWorld is an error used in the World function.
type ErrWorld string

// Error implements the error interface.
func (e ErrWorld) Error() string {
	return string(e)
}
