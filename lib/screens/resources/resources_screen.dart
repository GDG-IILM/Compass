// screens/resources/resources_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../models/note_model.dart';
import '../../services/auth_service.dart';

class ResourcesScreen extends StatefulWidget {
  @override
  _ResourcesScreenState createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  String _selectedBranch = 'All';
  String _selectedSemester = 'All';

  final List<String> _branches = [
    'All',
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
  ];

  final List<String> _semesters = [
    'All', '1', '2', '3', '4', '5', '6', '7', '8'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resource Hub'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Notes'),
            Tab(text: 'Books'),
            Tab(text: 'Videos'),
            Tab(text: 'Tools'),
          ],
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotesTab(),
                _buildBooksTab(),
                _buildVideosTab(),
                _buildToolsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedBranch,
              decoration: InputDecoration(
                labelText: 'Branch',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _branches.map((branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Text(branch, style: GoogleFonts.roboto(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBranch = value!;
                });
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSemester,
              decoration: InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _semesters.map((semester) {
                return DropdownMenuItem(
                  value: semester,
                  child: Text(semester == 'All' ? 'All' : 'Sem $semester',
                      style: GoogleFonts.roboto(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No notes available', Icons.note_outlined);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final note = NoteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            return _buildNoteCard(note);
          },
        );
      },
    );
  }

  Widget _buildBooksTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildBookCard(
          'Data Structures and Algorithms',
          'Thomas H. Cormen',
          'https://example.com/dsa-book',
          'Computer Science',
          3,
        ),
        _buildBookCard(
          'Database Systems',
          'Ramez Elmasri',
          'https://example.com/db-book',
          'Computer Science',
          4,
        ),
        _buildBookCard(
          'Digital Electronics',
          'R.P. Jain',
          'https://example.com/de-book',
          'Electronics & Communication',
          2,
        ),
      ],
    );
  }

  Widget _buildVideosTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildVideoCard(
          'Introduction to Programming',
          'CS50 Harvard',
          'https://youtube.com/watch?v=example1',
          Duration(hours: 2, minutes: 30),
        ),
        _buildVideoCard(
          'Data Structures Explained',
          'MIT OpenCourseWare',
          'https://youtube.com/watch?v=example2',
          Duration(hours: 1, minutes: 45),
        ),
        _buildVideoCard(
          'Database Design Basics',
          'Stanford Online',
          'https://youtube.com/watch?v=example3',
          Duration(hours: 3, minutes: 15),
        ),
      ],
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildToolCard(
          'Visual Studio Code',
          'Free code editor with extensions',
          'https://code.visualstudio.com',
          Icons.code,
          AppColors.primary,
        ),
        _buildToolCard(
          'Git & GitHub',
          'Version control and collaboration',
          'https://github.com',
          Icons.storage,
          AppColors.success,
        ),
        _buildToolCard(
          'Figma',
          'Design and prototyping tool',
          'https://figma.com',
          Icons.design_services,
          AppColors.warning,
        ),
        _buildToolCard(
          'Notion',
          'All-in-one workspace for notes',
          'https://notion.so',
          Icons.note_alt,
          AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openUrl(note.fileUrl),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          note.subject,
                          style: GoogleFonts.roboto(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                  ),
                ],
              ),
              if (note.description.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  note.description,
                  style: GoogleFonts.roboto(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      note.branch,
                      style: GoogleFonts.roboto(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sem ${note.semester}',
                      style: GoogleFonts.roboto(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'By ${note.uploaderName}',
                    style: GoogleFonts.roboto(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(String name, String description, String url, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openUrl(url),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.roboto(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.launch,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Be the first to upload!',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredNotesStream() {
    Query query = FirebaseFirestore.instance.collection('notes');

    if (_selectedBranch != 'All') {
      query = query.where('branch', isEqualTo: _selectedBranch);
    }

    if (_selectedSemester != 'All') {
      query = query.where('semester', isEqualTo: int.parse(_selectedSemester));
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => UploadResourceDialog(),
    );
  }

  void _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class UploadResourceDialog extends StatefulWidget {
  @override
  _UploadResourceDialogState createState() => _UploadResourceDialogState();
}

class _UploadResourceDialogState extends State<UploadResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();

  String _selectedBranch = 'Computer Science';
  int _selectedSemester = 1;
  bool _isLoading = false;

  final List<String> _branches = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Resource',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the subject';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'File URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Google Drive, Dropbox, etc.',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the file URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedBranch,
                            decoration: InputDecoration(
                              labelText: 'Branch',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _branches.map((branch) {
                              return DropdownMenuItem(
                                value: branch,
                                child: Text(branch),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBranch = value!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedSemester,
                            decoration: InputDecoration(
                              labelText: 'Semester',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: List.generate(8, (index) => index + 1).map((semester) {
                              return DropdownMenuItem(
                                value: semester,
                                child: Text('Semester $semester'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSemester = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _uploadResource,
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Upload Resource',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadResource() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      // Get user name
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('notes').add({
        'title': _titleController.text.trim(),
        'subject': _subjectController.text.trim(),
        'description': _descriptionController.text.trim(),
        'fileUrl': _urlController.text.trim(),
        'branch': _selectedBranch,
        'semester': _selectedSemester,
        'uploaderId': user.uid,
        'uploaderName': userName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resource uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}

// models/note_model.dart
class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String fileUrl;
  final String branch;
  final int semester;
  final String uploaderId;
  final String uploaderName;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.fileUrl,
    required this.branch,
    required this.semester,
    required this.uploaderId,
    required this.uploaderName,
    required this.createdAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? 1,
      uploaderId: map['uploaderId'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'fileUrl': fileUrl,
      'branch': branch,
      'semester': semester,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'createdAt': createdAt,
    };
  }
});
}

Widget _buildBookCard(String title, String author, String url, String branch, int semester) {
  return Card(
    margin: EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openUrl(url),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'by $author',
                    style: GoogleFonts.roboto(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          branch,
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Sem $semester',
                          style: GoogleFonts.roboto(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildVideoCard(String title, String channel, String url, Duration duration) {
  return Card(
      margin: EdgeInsets.only(bottom: 12),
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: InkWell(
  borderRadius: BorderRadius.circular(12),
  onTap: () => _openUrl(url),
  child: Padding(
  padding: EdgeInsets.all(16),
  child: Row(
  children: [
  Container(
  width: 60,
  height: 45,
  decoration: BoxDecoration(
  color: AppColors.error.withOpacity(0.1),
  borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(
  Icons.play_arrow,
  color: AppColors.error,
  size: 24,
  ),
  ),
  SizedBox(width: 16),
  Expanded(
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  title,
  style: GoogleFonts.poppins(
  fontWeight: FontWeight.w600,
  fontSize: 16,
  color: AppColors.textPrimary,
  ),
  ),
  SizedBox(height: 4),
  Text(
  channel,
  style: GoogleFonts.roboto(
  color: AppColors.textSecondary,
  fontSize: 14,
  ),
  ),
  SizedBox(height: 4),
  Text(
  '${duration.inHours}h ${duration.inMinutes % 60}m',
  style: GoogleFonts.roboto(
  color: AppColors.primary,
  fontSize: 12,
  fontWeight: FontWeight.w500,
  ),
  ),
  ],
  ),
  ),
  Icon(
  Icons.play_circle_outline,
  color: AppColors.error,
  size: 24,
  ),
  ],
  ),
  ),
  ),