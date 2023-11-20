import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/dependency_injection/di_container.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/auth/domain/bloc/auth/auth_bloc.dart';
import 'package:todo_list/features/auth/domain/models/auth_user.model.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_bloc/grocery_bloc.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_title.models/add_title.model.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_title.models/delete_title.model.dart';
import 'package:todo_list/features/auth/grocery/domain/title_grocery_bloc/title_grocery_bloc.dart';
import 'package:todo_list/features/auth/grocery/presentation/grocery_item.dart';
import 'package:todo_list/features/auth/grocery/presentation/update_titlegrocery.dart';
import 'package:todo_list/features/auth/presentation/pages/home.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/features/auth/todo/domain/todo_bloc/todo_bloc.dart';

class GroceryTitlePage extends StatefulWidget {
  const GroceryTitlePage({super.key, required this.authUserModel});
  final AuthUserModel authUserModel;

  @override
  State<GroceryTitlePage> createState() => _GroceryTitlePageState();
}

class _GroceryTitlePageState extends State<GroceryTitlePage> {
  late TitleGroceryBloc _titleGroceryBloc;
  late AuthBloc _authBloc;

  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _email;
  late String userId;
  final GlobalKey<FormState> _formKey = GlobalKey();


  final TextEditingController _titleGrocery = TextEditingController();
  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _titleGroceryBloc = BlocProvider.of<TitleGroceryBloc>(context);

    userId = widget.authUserModel.userId;
    _authBloc.add(AuthAutoLoginEvent());
    _titleGroceryBloc.add(GetTitleGroceryEvent(userId: userId));

    _firstName = TextEditingController(text: widget.authUserModel.firstName);
    _lastName = TextEditingController(text: widget.authUserModel.lastName);
    _email = TextEditingController(text: widget.authUserModel.email);
  }

  final DIContainer diContainer = DIContainer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.stateStatus == StateStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return BlocConsumer<TitleGroceryBloc, TitleGroceryState>(
          bloc: _titleGroceryBloc,
          listener: _titleGroceryListener,
          builder: (context, titleGrocertyState) {
            if (titleGrocertyState.isUpdated) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Scaffold(
              appBar: AppBar(
                titleTextStyle: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                backgroundColor: Colors.black,
                title: const Center(child: Text('Grocery List')),
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
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(color: Colors.black54),
                      child: ListView(
                        children: <Widget>[
                          const Icon(Icons.person,
                              size: 70, color: Colors.white),
                          Column(
                            children: [
                              Text(
                                '${_firstName.text.capitalize()} ${_lastName.text.capitalize()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                _email.text,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MultiBlocProvider(
                              providers: [
                                BlocProvider<AuthBloc>(
                                    create: (BuildContext context) =>
                                        diContainer.authBloc),
                                BlocProvider<TodoBloc>(
                                    create: (BuildContext context) =>
                                        diContainer.todoBloc),
                                BlocProvider<TitleGroceryBloc>(
                                    create: (BuildContext context) =>
                                        diContainer.titleGroceryBloc),
                              ],
                              child: HomePage(
                                authUserModel: state.authUserModel!,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag_rounded,
                          color: Colors.grey),
                      title: const Text('Grocery'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              body: Builder(builder: (context) {
                if (titleGrocertyState.stateStatus == StateStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (titleGrocertyState.isEmpty) {
                  return const SizedBox(
                    child: Center(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'No Grocery',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
                if (titleGrocertyState.isDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grocery deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: titleGrocertyState.titleGroceryList.length,
                  itemBuilder: (context, index) {
                    final titleList =
                        titleGrocertyState.titleGroceryList[index];

                    //Convert createdAt dateTime from appwrite to DD/MM/YY format
                    String titleDate = titleList.createdAt!;
                    String formattedDate = DateFormat('EEE, M/d/y')
                        .format(DateTime.parse(titleDate));

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
                                  'Do you confirm deleting this list?'),
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
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) => BlocProvider.value(
                                          //       value: _titleGroceryBloc,
                                          //       child: UpdateGroceryTitlePage(
                                          //         groceryTitleModel: titleList,
                                          //       ),
                                          //     ),
                                          //   ),
                                          _deleteTitleGrocery(
                                            context,
                                            titleList.id,
                                          );
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
                              builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider<AuthBloc>(
                                      create: (BuildContext context) =>
                                          diContainer.authBloc,
                                    ),
                                    BlocProvider<TitleGroceryBloc>(
                                      create: (BuildContext context) =>
                                          diContainer.titleGroceryBloc,
                                    ),
                                    BlocProvider<GroceryItemBloc>(
                                        create: (BuildContext context) =>
                                            diContainer.groceryItemBloc)
                                  ],
                                  child: ProductPage(
                                    groceryTitleModel: titleList,
                                  )),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            child: ListTile(
                              title: Text(titleList.title),
                              subtitle: Text(formattedDate),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.edit_rounded,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: _titleGroceryBloc,
                                        child: UpdateGroceryTitlePage(
                                          groceryTitleModel: titleList,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                onPressed: () {
                  _displayAddDialog(context);
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _titleGroceryListener(
      BuildContext context, TitleGroceryState titleGroceryState) {
    if (titleGroceryState.stateStatus == StateStatus.error) {
      const Center(child: CircularProgressIndicator());
      SnackBarUtils.defualtSnackBar(titleGroceryState.errorMessage, context);
    }
    if (titleGroceryState.isDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grocery deleted!'),
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
              scrollable: true,
              title: const Center(child: Text('Add Grocery List')),
              content: Column(
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _titleGrocery,
                    autofocus: true,
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
                      }
                  ),
                ],
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('   ADD   '),
                      onPressed: () {
                        _addtitleGroceries(context);
                       
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _addtitleGroceries(BuildContext context) {
    if(_formKey.currentState!.validate()){
      _titleGroceryBloc.add(
      AddTitleGroceryEvent(
        addTitleGroceryModel: AddTitleGroceryModel(
          title: _titleGrocery.text,
          userId: userId,
        ),
      ),
    );
     _titleGrocery.clear();
    Navigator.of(context).pop();
    
    }
     
  }

  void _deleteTitleGrocery(BuildContext context, String id) {
    _titleGroceryBloc.add(DeleteTitleGroceryEvent(
        deleteTitleGroceryModel: DeleteTitleGroceryModel(id: id)));

    Navigator.of(context).pop();
  }
}
