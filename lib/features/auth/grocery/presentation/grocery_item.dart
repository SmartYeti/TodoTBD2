import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_bloc/grocery_bloc.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_title.models/grocery_title.model.dart';
import 'package:todo_list/features/auth/grocery/domain/models/add_grocery.model.dart';
import 'package:todo_list/features/auth/grocery/domain/models/delete_grocery.model.dart';
import 'package:todo_list/features/auth/grocery/domain/title_grocery_bloc/title_grocery_bloc.dart';
import 'package:todo_list/features/auth/grocery/presentation/update_itemgrocery.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.groceryTitleModel});
  final GroceryTitleModel groceryTitleModel;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late GroceryItemBloc _groceryBloc;

  late TitleGroceryBloc _titleGroceryBloc;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late String groceryId;
  late String title;

  @override
  void initState() {
    super.initState();
    //get ID from groceryTitleModel
    groceryId = widget.groceryTitleModel.id;

    _titleGroceryBloc = BlocProvider.of<TitleGroceryBloc>(context);
    _titleGroceryBloc.add(GetTitleGroceryEvent(userId: groceryId));

    //kani gi gamit para sa title kay di makita ang value sa id ingani-on kani pasabot sa ubos
    title = widget.groceryTitleModel.title;

    _groceryBloc = BlocProvider.of<GroceryItemBloc>(context);
    _groceryBloc.add(GetGroceryEvent(titleID: groceryId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TitleGroceryBloc, TitleGroceryState>(
      bloc: _titleGroceryBloc,
      listener: _titleGroceryListener,
      builder: (context, state) {
        //kani pasabot sa babaw
        // final title =
        //     state.titleGroceryList.where((e) => e.id == groceryId).first.title;
        if (state.stateStatus == StateStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.isUpdated) {
          Navigator.pop(context);
          SnackBarUtils.defualtSnackBar(
              'Grocery successfully updated!', context);
        }
        return Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.shopping_bag, color: Colors.white,),
            titleTextStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            backgroundColor: Colors.black,
            title: Text('$title List'),
          ),
          body: BlocConsumer<GroceryItemBloc, GroceryItemState>(
            listener: _groceryListener,
            builder: (context, groceryState) {
              if (groceryState.stateStatus == StateStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (groceryState.isEmpty) {
                return const SizedBox(
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        'No Groceries',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                );
              }
              if (groceryState.isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              return ListView.builder(
                itemCount: groceryState.groceryList.length,
                itemBuilder: (context, index) {
                  final groceryList = groceryState.groceryList[index];
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
                            content: Text(
                                'Do you confirm deleting ${groceryList.productName}?'),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                                alignment: Alignment.centerLeft,
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                 ),
                                      onPressed: () {
                                        _deleteItem(context, groceryList.id);
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
                              value: _groceryBloc,
                              child: UpdateGroceryItemPage(
                                groceryItemModel: groceryList,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(
                            groceryList.productName,
                            style: const TextStyle(fontSize: 15),
                          ),
                          leading: Text(
                            groceryList.quantity,
                            style: const TextStyle(fontSize: 15),
                          ),
                          trailing: Text(
                            'Php${groceryList.price}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: IconButton(
                  
                  iconSize: 35,
                  icon: const Icon(
                    
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    
                    ), onPressed: () {
                  // _displayAddDialog(context);
                  Navigator.pop(context);
                  },
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  _displayAddDialog(context);
                },
                child: const Icon(Icons.add, color: Colors.white,),
              ),
            ],
          ),
        );
      },
    );
  }

  void _groceryListener(
      BuildContext context, GroceryItemState titleGroceryState) {
    if (titleGroceryState.stateStatus == StateStatus.error) {
      const Center(child: CircularProgressIndicator());
      SnackBarUtils.defualtSnackBar(titleGroceryState.errorMessage, context);
    }
    if (titleGroceryState.isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
  }

  void _titleGroceryListener(
      BuildContext context, TitleGroceryState titleGroceryState) {
    if (titleGroceryState.stateStatus == StateStatus.error) {
      const Center(child: CircularProgressIndicator());
      SnackBarUtils.defualtSnackBar(titleGroceryState.errorMessage, context);
    }
  }

  Future _displayAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            scrollable: true,
            title: const Center(child: Text('Add Groceries')),
            content: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _productNameController,
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
                                labelText: 'Product Name',
                        ),
                        validator: (String? val) {
                        return Guard.againstEmptyString(val, 'Product Name');
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    controller: _quantityController,
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
                                labelText: 'Quantity',
                        ),
                        validator: (String? val) {
                        return Guard.againstEmptyString(val, 'Quantity');
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    controller: _priceController,
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
                                labelText: 'Price',
                        ),
                        validator: (String? val) {
                        return Guard.againstEmptyString(val, 'Price');
                      }
                  ),
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
                      _addGroceries(context);
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
      },
    );
  }

  void _addGroceries(BuildContext context) {
    if(_formKey.currentState!.validate()){
      _groceryBloc.add(AddGroceryEvent(
        addGroceryModel: AddGroceryModel(
      productName: _productNameController.text,
      quantity: _quantityController.text,
      price: _priceController.text,
      titleId: groceryId,
    ))
    );
    
     Navigator.of(context).pop();
     _productNameController.clear();
      _quantityController.clear();
     _priceController.clear();
    }
    
  }

  void _deleteItem(BuildContext context, String id) {
    _groceryBloc.add(
        DeleteGroceryEvent(deleteGroceryModel: DeleteGroceryModel(id: id)));
    Navigator.of(context).pop();
  }
}
