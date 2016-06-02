## Synopsis

This project gives a class which allows schedule blocks.

The blcok are submited with three parameters, name, isActive and time.
The time is the period of seconds between each block call, this period could be start at any time.
By any time we mean before the block is called, during the block process and after the block is executed.
The active parameter will determine if at desired period of time gone the block is called or wait to the next periodo.
If isActive is true the block is called, other way not.
The name is like the key used internally the Daemon class used in the internal dictionary.
The class provide a default object but nothing stop the user to gave many Daemon objects.

## Code Example

Show what the library does as concisely as possible, developers should be able to figure out **how** your project solves their problem by looking at the code example. Make sure the API you are showing off is obvious, and that your code is short and concise.

## Motivation

A short description of the motivation behind the creation and maintenance of the project. This should explain **why** the project exists.

## Installation

Provide code examples and explanations of how to get the project.

## API Reference

Depending on the size of the project, if it is small and simple enough the reference docs can be added to the README. For medium size to larger projects it is important to at least provide a link to where the API reference docs live.

## Tests

Describe and show how to run the tests with code examples.

## Contributors

Let people know how they can dive into the project, include important links to things like issue trackers, irc, twitter accounts if applicable.

## License

A short snippet describing the license (MIT, Apache, etc.)
