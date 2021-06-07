import ui

const (
	w_width  = 400
	w_height = 600
	w_title  = 'V DO'
)

struct Task {
mut:
	title string
	done  bool
}

struct State {
mut:
	tasks       []Task
	window      &ui.Window = voidptr(0)
	task_column &ui.Stack  = voidptr(0)
}

fn main() {
	mut app := &State{
		tasks: [
			{
				title: 'test'
				done: false
			},
			{
				title: 'test 2'
				done: false
			},
		]
	}

	task_column := ui.column({}, tasks(app))

	window := ui.window({
		width: w_width
		height: w_height
		state: app
		title: w_title
		mode: .resizable
	}, [ui.column({}, [task_column, ui.button(text: '+', onclick: add_task)])])

	app.window = task_column
	app.window = window
	ui.run(window)
}

fn tasks(app &State) []ui.Widget {
	mut tasks := []ui.Widget{}

	for task in app.tasks {
		tasks << ui.row({}, [
			ui.checkbox(checked: task.done),
			ui.label(text: task.title),
		])
	}

	return tasks
}

fn add_task(mut app State, x voidptr) {
	// new_task := {
	// 	title: 'new'
	// 	done: false
	// }
	// app.tasks << new_task
}
