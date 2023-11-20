import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/dependency_injection/di_container.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/auth/domain/bloc/auth/auth_bloc.dart';
import 'package:todo_list/features/auth/domain/models/auth_user.model.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_bloc/grocery_bloc.dart';
import 'package:todo_list/features/auth/grocery/domain/title_grocery_bloc/title_grocery_bloc.dart';
import 'package:todo_list/features/auth/grocery/presentation/grocery_title.dart';
import 'package:todo_list/features/auth/presentation/pages/login.dart';
import 'package:todo_list/features/auth/todo/domain/models/add_todo.model.dart';
import 'package:todo_list/features/auth/todo/domain/models/check_model.dart';
import 'package:todo_list/features/auth/todo/domain/models/delete.model.dart';
import 'package:todo_list/features/auth/todo/domain/todo_bloc/todo_bloc.dart';
import 'package:todo_list/features/auth/todo/presentation/todo_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.authUserModel});
  final AuthUserModel authUserModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DIContainer diContainer = DIContainer();
  late AuthBloc _authBloc;
  late TodoBloc _todoBloc;
  final GlobalKey<FormState> _formKey = GlobalKey();

  late String userId;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);

    userId = widget.authUserModel.userId;

    _todoBloc.add(GetTodoEvent(userId: userId));
    _authBloc.add(AuthAutoLoginEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: _authListener,
      builder: (context, state) {
        if (state.stateStatus == StateStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return BlocConsumer<TodoBloc, TodoState>(
          bloc: _todoBloc,
          listener: _todoListener,
          builder: (context, todoState) {
            if (todoState.isUpdated) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return PopScope(
              canPop: false,
              child: Scaffold(
                drawer: Drawer(
                  child: Builder(builder: (context) {
                    final userId = state.authUserModel;
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          decoration:
                              const BoxDecoration(color: Colors.black54),
                          child: ListView(
                            children: <Widget>[
                              const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${userId!.firstName.capitalize()} ${userId.lastName.capitalize()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    userId.email,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.checklist_rounded,
                              color: Colors.grey),
                          title: const Text('To Do'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.shopping_bag_rounded,
                              color: Colors.grey),
                          title: const Text('Grocery'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    MultiBlocProvider(
                                  providers: [
                                    BlocProvider<TitleGroceryBloc>(
                                      create: (BuildContext context) =>
                                          diContainer.titleGroceryBloc,
                                    ),
                                    BlocProvider<GroceryItemBloc>(
                                        create: (BuildContext context) =>
                                            diContainer.groceryItemBloc),
                                    BlocProvider.value(
                                      value: _authBloc,
                                    ),
                                  ],
                                  child: GroceryTitlePage(
                                    authUserModel: userId,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),
                ),
                appBar: AppBar(
                  titleTextStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  backgroundColor: Colors.black,
                  title: const Center(child: Text('Home')),
                  actions: <Widget>[
                    IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ))
                  ],
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                ),
                body: Builder(builder: (context) {
                  if (todoState.stateStatus == StateStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (todoState.isEmpty) {
                    return const SizedBox(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            'No ToDo',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }
                  if (todoState.isDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task successfully deleted'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: todoState.todoList.length,
                    itemBuilder: (context, index) {
                      final item = todoState.todoList[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) {
                          return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'Delete',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Do you confirm deleting this task?',
                                ),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            _deleteTask(context, item.id);
                                          },
                                          child: const Text('Delete')),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel')),
                                    ],
                                  )
                                ],
                              );
                            },
                          );
                        },
                        background: Container(
                          color: Colors.lightGreen[200],
                          child: const Padding(
                            padding: EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Icon(Icons.delete), Text('Delete')],
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: _todoBloc,
                                  child: MyFormPage(
                                    todoModel: item,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Card(
                              child: ListTile(
                                title: Text(item.title),
                                subtitle: Text(item.description),
                                trailing: Checkbox(
                                    value: item.isChecked,
                                    onChanged: (bool? newIsChecked) {
                                      _checkListener(context, item.id,
                                          newIsChecked ?? false);
                                    }),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _displayAddDialog(context);
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state.stateStatus == StateStatus.error) {
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
      return;
    }

    if (state.stateStatus == StateStatus.initial) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MultiBlocProvider(providers: [
              BlocProvider<AuthBloc>(
                  create: (BuildContext context) => diContainer.authBloc),
              BlocProvider<TodoBloc>(
                  create: (BuildContext context) => diContainer.todoBloc)
            ], child: const LoginPage()),
          ),
          ModalRoute.withName('/'));
    }
  }

  void _todoListener(BuildContext context, TodoState state) {
    if (state.stateStatus == StateStatus.error) {
      const Center(child: CircularProgressIndicator());
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
    }

    if (state.isDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task successfully deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _logout() {
    _authBloc.add(AuthLogoutEvent());
  }

  Future _displayAddDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: AlertDialog(
              // backgroundColor: Colors.grey,
              scrollable: true,
              title: const Center(
                  child: Text(
                'Add ToDo',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              content: Column(
                children: [
                  TextFormField(
                      controller: _titleController,
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.green,
                        ),
                        labelText: 'Title',
                      ),
                      validator: (String? val) {
                        return Guard.againstEmptyString(val, 'Title');
                      }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _descriptionController,
                          autofocus: true,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelStyle: const TextStyle(
                              color: Colors.green,
                            ),
                            labelText: 'Description',
                          ),
                          validator: (String? val) {
                            return Guard.againstEmptyString(val, 'Description');
                          }),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),

                        child: const Text('    ADD    '),
                        
                        onPressed: () {
                          // _addTask(context);
                          // Navigator.of(context).pop();
                          // _titleController.clear();
                          // _descriptionController.clear();
                          _authAdd(context);
                        },
                      ),
                      // const SizedBox(width:40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerRight,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  // void _addTask(BuildContext context) {
  //   _todoBloc.add(
  //     AddTodoEvent(
  //       addtodoModel: AddTodoModel(
  //         title: _titleController.text,
  //         description: _descriptionController.text,
  //         userId: userId,
  //       ),
  //     ),
  //   );
  // }

  void _checkListener(BuildContext context, String id, bool isChecked) {
    _todoBloc.add(
      CheckedEvent(
        checkTodoModel: CheckTodoModel(
          id: id,
          isChecked: isChecked,
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, String id) {
    _todoBloc.add(
      DeleteTodoEvent(
        deleteTaskModel: DeleteTaskModel(id: id),
      ),
    );

    Navigator.of(context).pop();
  }

  void _authAdd(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // _addTask(context);
      // Navigator.of(context).pop();
      // _titleController.clear();
      // _descriptionController.clear();
      _todoBloc.add(
        AddTodoEvent(
            addtodoModel: AddTodoModel(
          title: _titleController.text,
          description: _descriptionController.text,
          userId: userId,
        )),
      );
      Navigator.of(context).pop();
    }
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
