import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const url='https://evaammherpizsntcbzbf.supabase.co';
const key='sb_publishable_ZYPPNKKdKoi2-_gMiIl-cw_nJ87SQCZ';
const purple=Color(0xFF8B5CF6), panel=Color(0xFF141A29);
final db=Supabase.instance.client;
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await Supabase.initialize(url:url,publishableKey:key); runApp(const AdminApp()); }
class AdminApp extends StatelessWidget { const AdminApp({super.key}); @override Widget build(BuildContext c)=>MaterialApp(title:'PromptGo Admin',debugShowCheckedModeBanner:false,theme:ThemeData(brightness:Brightness.dark,scaffoldBackgroundColor:const Color(0xFF080A12),colorScheme:const ColorScheme.dark(primary:purple,surface:panel),useMaterial3:true),home:const AdminPage()); }
class AdminPage extends StatefulWidget { const AdminPage({super.key}); @override State<AdminPage> createState()=>_AdminPageState(); }
class _AdminPageState extends State<AdminPage>{
 List<Map<String,dynamic>> prompts=[],cats=[]; bool loading=true; String? error;
 @override void initState(){super.initState();load();}
 Future<void> load() async {setState(()=>loading=true);try{final r=await Future.wait([db.from('prompts').select('id,title,image_url,prompt_text,category_id,is_featured,created_at').order('created_at',ascending:false),db.from('categories').select('id,name,slug,sort_order').order('sort_order')]);if(!mounted)return;setState(() { prompts=(r[0] as List).map((e)=>Map<String,dynamic>.from(e)).toList(); cats=(r[1] as List).map((e)=>Map<String,dynamic>.from(e)).toList(); });}catch(_){if(mounted)setState(()=>error='Could not load data. Check internet connection.');}finally{if(mounted)setState(()=>loading=false);}}
 Future<void> write(String action,Map<String,dynamic> data) async {await db.functions.invoke('promptgo-admin',body:{'action':action,...data});await load();}
 Future<void> promptForm([Map<String, dynamic>? old]) async {
    final title = TextEditingController(text: old?['title']?.toString() ?? '');
    final image = TextEditingController(text: old?['image_url']?.toString() ?? '');
    final body = TextEditingController(text: old?['prompt_text']?.toString() ?? '');
    String? cat = old?['category_id']?.toString();
    bool featured = old?['is_featured'] == true;
    final form = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refresh) {
          final validCategory = cats.any((x) => x['id'].toString() == cat);
          return AlertDialog(
            title: Text(old == null ? 'Add Prompt' : 'Edit Prompt'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: image,
                        decoration: const InputDecoration(labelText: 'HTTPS Image URL'),
                        validator: (v) => v == null || !v.startsWith('https://') ? 'Enter HTTPS URL' : null,
                      ),
                      TextFormField(
                        controller: body,
                        minLines: 4,
                        maxLines: 8,
                        decoration: const InputDecoration(labelText: 'Prompt text'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: validCategory ? cat : null,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: cats
                            .map((x) => DropdownMenuItem<String>(
                                  value: x['id'].toString(),
                                  child: Text(x['name'].toString()),
                                ))
                            .toList(),
                        onChanged: (v) => refresh(() => cat = v),
                      ),
                      SwitchListTile(
                        title: const Text('Featured'),
                        value: featured,
                        onChanged: (v) => refresh(() => featured = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!form.currentState!.validate()) return;
                  Navigator.pop(ctx);
                  try {
                    await write(
                      old == null ? 'create_prompt' : 'update_prompt',
                      {
                        'id': old?['id'],
                        'title': title.text.trim(),
                        'image_url': image.text.trim(),
                        'prompt_text': body.text.trim(),
                        'category_id': cat,
                        'is_featured': featured,
                      },
                    );
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Save failed: secure Admin API not configured')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    title.dispose();
    image.dispose();
    body.dispose();
  }

  Future<void> categoryForm([Map<String,dynamic>? old]) async {final n=TextEditingController(text:old?['name']?.toString()??''),s=TextEditingController(text:old?['slug']?.toString()??'');await showDialog(context:context,builder:(ctx)=>AlertDialog(title:Text(old==null?'Add Category':'Edit Category'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:n,decoration:const InputDecoration(labelText:'Name')),TextField(controller:s,decoration:const InputDecoration(labelText:'Slug'))]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),FilledButton(onPressed:()async{Navigator.pop(ctx);try{await write(old==null?'create_category':'update_category',{'id':old?['id'],'name':n.text.trim(),'slug':s.text.trim()});}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Save failed: secure Admin API not configured')));}},child:const Text('Save'))]));n.dispose();s.dispose();}
 Future<void> remove(String kind,Map<String,dynamic> x) async {final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Confirm delete'),content:Text('Delete '+(x['title']??x['name']).toString()+'?'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Delete'))]));if(ok==true){try{await write(kind=='prompt'?'delete_prompt':'delete_category',{'id':x['id']});}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Delete failed: secure Admin API not configured')));}}}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('PromptGo Admin'),actions:[IconButton(onPressed:load,icon:const Icon(Icons.refresh))]),floatingActionButton:FloatingActionButton.extended(onPressed:()=>promptForm(),icon:const Icon(Icons.add),label:const Text('Add Prompt')),body:loading?const Center(child:CircularProgressIndicator()):error!=null?Center(child:Text(error!)):RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(16),children:[Row(children:[Expanded(child:Card(color:panel,child:Padding(padding:const EdgeInsets.all(16),child:Text('Prompts: '+prompts.length.toString())))),Expanded(child:Card(color:panel,child:Padding(padding:const EdgeInsets.all(16),child:Text('Categories: '+cats.length.toString()))))]),Row(children:[const Expanded(child:Text('Categories',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold))),TextButton.icon(onPressed:()=>categoryForm(),icon:const Icon(Icons.add),label:const Text('Add'))]),...cats.map((x)=>Card(color:panel,child:ListTile(title:Text(x['name'].toString()),trailing:PopupMenuButton<String>(onSelected:(v)=>v=='edit'?categoryForm(x):remove('category',x),itemBuilder:(_)=>const[PopupMenuItem(value:'edit',child:Text('Edit')),PopupMenuItem(value:'delete',child:Text('Delete'))])))),const SizedBox(height:20),const Text('All Prompts',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),...prompts.map((x)=>Card(color:panel,child:ListTile(title:Text(x['title']?.toString()??'Untitled'),subtitle:Text(x['is_featured']==true?'Featured':'Prompt'),trailing:PopupMenuButton<String>(onSelected:(v)=>v=='edit'?promptForm(x):remove('prompt',x),itemBuilder:(_)=>const[PopupMenuItem(value:'edit',child:Text('Edit')),PopupMenuItem(value:'delete',child:Text('Delete'))])))),const SizedBox(height:90)])));
}
