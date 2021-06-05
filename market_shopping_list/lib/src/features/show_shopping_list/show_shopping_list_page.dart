import 'package:flutter/material.dart';
import 'package:market_shopping_list/src/core/colors_util.dart';
import 'package:market_shopping_list/src/features/show_shopping_list/show_shopping_list_controller.dart';
import 'package:market_shopping_list/src/shared/models/purchase_item.dart';
import 'package:market_shopping_list/src/shared/models/shopping_list.dart';
import 'package:asuka/asuka.dart' as asuka;
import 'package:rx_notifier/rx_notifier.dart';

class ShowShoppingListPage extends StatefulWidget {
  ShoppingList shopping;
  ShowShoppingListPage({
    Key? key,
    required this.shopping,
  }) : super(key: key);
  @override
  SshoSshopping_listLatePage createState() => SshoSshopping_listLatePage();
}

class SshoSshopping_listLatePage extends State<ShowShoppingListPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ShowShoppingListController controller;

  @override
  void initState() {
    controller = ShowShoppingListController(shoppingList: widget.shopping);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: size.width,
                  color: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        controller.shoppingList.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        controller.shoppingList.description != null ? controller.shoppingList.description! : '',
                        style: TextStyle(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(
                            backgroundColor: AppColors.primaryColor.withAlpha(50),
                            avatar: CircleAvatar(
                              backgroundColor: controller.shoppingList.isDone ? Colors.lightGreen : AppColors.primaryColorLight,
                            ),
                            label: Text(
                              '${controller.shoppingList.isDone ? "Concluída" : "Andamento"}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.0),
                          Chip(
                            backgroundColor: AppColors.primaryColor.withAlpha(50),
                            label: Text(
                              'Criada em ${controller.creationDate()}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        backgroundColor: Colors.white,
                        label: Text(
                          'Total: R\$ ${controller.formatDoubleValue(controller.getTotal())}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.edit_outlined, color: Colors.white),
                            label: Text('Editar dados', style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white, width: 2)),
                            onPressed: () => controller.goToEditShoppingListPage(context),
                          ),
                          SizedBox(width: 8.0),
                          OutlinedButton.icon(
                            icon: Icon(Icons.delete_outline, color: Colors.white),
                            label: Text('lista de compras', style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white, width: 2)),
                            onPressed: () => confirmDeleteList(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                RxBuilder(
                  builder: (context) => ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.itens.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, index) {
                      PurchaseItem item = controller.itens[index];
                      return ListTile(
                        leading: Icon(Icons.shopping_basket_outlined),
                        title: Text('${item.quantity} X ${item.productName}'),
                        subtitle: Text('Total: R\$ ${controller.formatDoubleValue(item.quantity * item.price)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => this.confirmRemoveItem(item),
                        ),
                        onTap: () {
                          showAddItemDialog(item: item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Item'),
          onPressed: () {
            showAddItemDialog();
          },
        ),
      ),
    );
  }

  void showAddItemDialog({PurchaseItem? item}) {
    asuka.showDialog(
      builder: (dialogContext) => AlertDialog(
        title: Text('Item'),
        content: Wrap(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: item != null ? item.productName : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Arrox',
                      labelText: 'Produto',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite o nome do produto';
                      } else if (value.length >= 20) {
                        return 'O limite é 20 caracteres';
                      }
                    },
                    onSaved: (value) => controller.purchaseItem.productName = value!,
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    initialValue: item != null ? item.price.toString() : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 0.00',
                      labelText: 'preço',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      } else if (value.indexOf(',') != -1) {
                        return 'vírgulas não são válidas';
                      } else if (!controller.isNumeric(value)) {
                        return 'O valor não é válido';
                      }
                    },
                    onSaved: (value) => controller.purchaseItem.price = double.parse(value!.replaceAll(',', '.')),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    initialValue: item != null ? item.quantity.toString() : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '0',
                      labelText: 'Quantidade',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      } else if (value.indexOf(',') != -1) {
                        return 'vírgulas não são válidas';
                      } else if (!controller.isNumeric(value)) {
                        return 'O valor não é válido';
                      }
                    },
                    onSaved: (value) {
                      double doubleValue = double.parse(value!.replaceAll(',', '.'));
                      controller.purchaseItem.quantity = doubleValue.toInt();
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                            'Salvar',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(backgroundColor: AppColors.primaryColor),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              controller.saveItem(purchaseItem: item);
                              Navigator.pop(dialogContext);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmRemoveItem(PurchaseItem item) {
    asuka.showDialog(
      builder: (dialogContext) => AlertDialog(
        title: Text('atenção'),
        content: Text('Você realmente deseja remover o item da lista de compras?'),
        actions: [
          TextButton(
            child: Text('Não'),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
          TextButton(
            child: Text('Sim'),
            onPressed: () {
              controller.removeItem(item);
              Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }

  void confirmDeleteList() {
    asuka.showDialog(
      builder: (dialogContext) => AlertDialog(
        title: Text('atenção'),
        content: Text('Você realmente deseja deletar a lista de compras atual?'),
        actions: [
          TextButton(
            child: Text('Não'),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
          TextButton(
            child: Text('Sim'),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
