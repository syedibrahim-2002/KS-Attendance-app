const fs = require('fs');
const path = require('path');

function writeFile(targetPath, contentLines) {
  const fullPath = path.join(__dirname, targetPath);
  fs.writeFileSync(fullPath, contentLines.join('\n'), 'utf8');
  console.log('Restored File: ' + targetPath);
}

// 1. app/admin/employees.tsx (With 173-Year Bug Fix)
const adminEmployees = [
  "import React, { useState, useEffect, useCallback } from 'react';",
  "import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert, 
Platform, Keyboard } from 'react-native';",
  "import { TextInput, Button, Modal, Portal, Provider, Switch, Chip, 
SegmentedButtons, FAB, Divider } from 'react-native-paper';",
  "import { Calendar } from 'react-native-calendars';",
  "import { Picker } from '@react-native-picker/picker';",
  "import { MaterialCommunityIcons } from '@expo/vector-icons';",
  "import { useAuth } from '../../src/context/AuthContext';",
  "import { api } from '../../src/services/api';",
  "",
  "const STATUS_COLORS = {",
  "  present: { key: 'present', color: '#4CAF50' },",
  "  'half-day': { key: 'halfday', color: '#FF9800' },",
  "  absent: { key: 'absent', color: '#F44336' },",
  "  leave: { key: 'leave', color: '#2196F3' },",
  "  holiday: { key: 'holiday', color: '#9C27B0' },",
  "};",
  "",
  "const getISTDate = () => {",
  "  const d = new Date();",
  "  const utc = d.getTime() + (d.getTimezoneOffset() * 60000);",
  "  return new Date(utc + (3600000 * 5.5));",
  "};",
  "",
  "const getISTMonthString = () => {",
  "  const d = getISTDate();",
  "  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, 
'0');",
  "};",
  "",
  "export default function EmployeesScreen() {",
  "  const { token } = useAuth();",
  "  const [view, setView] = useState('list');",
  "  const [employees, setEmployees] = useState([]);",
  "  const [loading, setLoading] = useState(false);",
  "",
  "  const [showModal, setShowModal] = useState(false);",
  "  const [editingEmployee, setEditingEmployee] = useState<any>(null);",
  "  const [formName, setFormName] = useState('');",
  "  const [formUsername, setFormUsername] = useState('');",
  "  const [formPassword, setFormPassword] = useState('');",
  "  const [formSalary, setFormSalary] = useState('');",
  "  const [formDoubleEnabled, setFormDoubleEnabled] = useState(false);",
  "",
  "  const [newEmployeePassword, setNewEmployeePassword] = useState('');",
  "  const [resettingPassword, setResettingPassword] = useState(false);",
  "",
  "  const [selectedEmployee, setSelectedEmployee] = useState('');",
  "  const [selectedMonth, setSelectedMonth] = useState(() => 
getISTMonthString());",
  "  const [attendanceData, setAttendanceData] = useState<any>({});",
  "  const [markedDates, setMarkedDates] = useState<any>({});",
  "  const [selectedDate, setSelectedDate] = useState('');",
  "  const [showStatusPicker, setShowStatusPicker] = useState(false);",
  "  const [customTime, setCustomTime] = useState('');",
  "",
  "  const fetchEmployees = useCallback(async () => {",
  "    if (!token) return;",
  "    setLoading(true);",
  "    try {",
  "      const data = await api.getUsers(token);",
  "      setEmployees(data);",
  "    } catch (e: any) {",
  "      Alert.alert('Error', e.message);",
  "    } finally {",
  "      setLoading(false);",
  "    }",
  "  }, [token]);",
  "",
  "  useEffect(() => { fetchEmployees(); }, [fetchEmployees]);",
  "",
  "  const fetchCalendarData = useCallback(async () => {",
  "    if (!token || !selectedEmployee || !selectedMonth) return;",
  "    try {",
  "      const data = await api.getUserMonthAttendance(token, 
selectedEmployee, selectedMonth);",
  "      const byDate: any = {};",
  "      const marks: any = {};",
  "      for (const record of data) {",
  "        byDate[record.date] = record;",
  "        const statusColor = STATUS_COLORS[record.status as keyof typeof 
STATUS_COLORS];",
  "        if (statusColor) {",
  "          marks[record.date] = { selected: true, selectedColor: 
statusColor.color };",
  "        }",
  "      }",
  "      setAttendanceData(byDate);",
  "      setMarkedDates(marks);",
  "    } catch {}",
  "  }, [token, selectedEmployee, selectedMonth]);",
  "",
  "  useEffect(() => {",
  "    if (view === 'calendar') fetchCalendarData();",
  "  }, [view, fetchCalendarData]);",
  "",
  "  const handleCreateOrUpdate = async () => {",
  "    if (!token) return;",
  "    try {",
  "      if (editingEmployee) {",
  "        const updateData: any = {};",
  "        if (formName) updateData.name = formName;",
  "        if (formSalary) updateData.dailySalary = 
parseFloat(formSalary);",
  "        updateData.doubleEnabled = formDoubleEnabled;",
  "        await api.updateUser(token, editingEmployee._id, updateData);",
  "        Alert.alert('Success', 'Employee updated');",
  "      } else {",
  "        if (!formName || !formUsername || !formPassword || !formSalary) 
{",
  "          Alert.alert('Error', 'All fields required'); return;",
  "        }",
  "        await api.createUser(token, {",
  "          name: formName, username: formUsername, password: 
formPassword,",
  "          dailySalary: parseFloat(formSalary), role: 'employee', 
doubleEnabled: formDoubleEnabled,",
  "        });",
  "        Alert.alert('Success', 'Employee created');",
  "      }",
  "      resetForm(); fetchEmployees();",
  "    } catch (e: any) { Alert.alert('Error', e.message); }",
  "  };",
  "",
  "  const handleDelete = async (userId: string) => {",
  "    if (!token) return;",
  "    Alert.alert('Confirm', 'Delete this employee?', [",
  "      { text: 'Cancel' },",
  "      { text: 'Delete', style: 'destructive', onPress: async () => {",
  "          try { await api.deleteUser(token, userId); fetchEmployees(); 
} catch(e:any) { Alert.alert('Error', e.message); }",
  "      } }",
  "    ]);",
  "  };",
  "",
  "  const handleEditEmployee = (emp: any) => {",
  "    setEditingEmployee(emp); setFormName(emp.name); 
setFormUsername(emp.username);",
  "    setFormSalary(String(emp.dailySalary || 0)); 
setFormDoubleEnabled(emp.doubleEnabled || false); setShowModal(true);",
  "  };",
  "",
  "  const resetForm = () => {",
  "    setShowModal(false); setEditingEmployee(null); setFormName(''); 
setFormUsername('');",
  "    setFormPassword(''); setFormSalary(''); 
setFormDoubleEnabled(false); setNewEmployeePassword('');",
  "  };",
  "",
  "  const handleResetEmployeePassword = async () => {",
  "    Keyboard.dismiss();",
  "    if (!token || !editingEmployee) return;",
  "    if (!newEmployeePassword) return Alert.alert('Error', 'Enter new 
password');",
  "    setResettingPassword(true);",
  "    try {",
  "      await api.resetUserPassword(token, editingEmployee._id, 
newEmployeePassword);",
  "      Alert.alert('Success', 'Password reset successfully');",
  "      setNewEmployeePassword('');",
  "    } catch (e: any) { Alert.alert('Error', e.message); } finally { 
setResettingPassword(false); }",
  "  };",
  "",
  "  const handleMarkAttendance = async (status: string) => {",
  "    if (!token || !selectedEmployee || !selectedDate) return;",
  "    try {",
  "      const payload: any = { userId: selectedEmployee, date: 
selectedDate, status };",
  "      if (customTime) payload.checkInTime = selectedDate + 'T' + 
customTime + ':00+05:30';",
  "      await api.markAttendanceManual(token, payload);",
  "      setShowStatusPicker(false); setCustomTime(''); 
fetchCalendarData();",
  "      Alert.alert('Success', 'Marked as ' + status);",
  "    } catch (e: any) { Alert.alert('Error', e.message); }",
  "  };",
  "",
  "  return (",
  "    <Provider>",
  "      <View style={{ flex: 1, backgroundColor: '#f5f5f5' }}>",
  "        <View style={{ padding: 16 }}>",
  "          <SegmentedButtons value={view} onValueChange={setView} 
buttons={[{ value: 'list', label: 'List' }, { value: 'calendar', label: 
'Manual' }]} />",
  "        </View>",
  "        {view === 'list' ? (",
  "          <ScrollView style={{ padding: 16 }}>",
  "            {employees.map((emp: any) => (",
  "              <View key={emp._id} style={{ backgroundColor: '#fff', 
padding: 16, marginBottom: 8, borderRadius: 8, flexDirection: 'row', 
justifyContent: 'space-between', alignItems: 'center' }}>",
  "                <View>",
  "                  <Text style={{ fontSize: 16, fontWeight: 'bold' 
}}>{emp.name}</Text>",
  "                  <Text style={{ color: '#666' }}>@{emp.username} • 
₹{emp.dailySalary}/day</Text>",
  "                </View>",
  "                <View style={{ flexDirection: 'row' }}>",
  "                  <TouchableOpacity onPress={() => 
handleEditEmployee(emp)} style={{ padding: 8 }}><MaterialCommunityIcons 
name='pencil' size={20} color='#D32F2F' /></TouchableOpacity>",
  "                  <TouchableOpacity onPress={() => 
handleDelete(emp._id)} style={{ padding: 8 }}><MaterialCommunityIcons 
name='delete' size={20} color='#F44336' /></TouchableOpacity>",
  "                </View>",
  "              </View>",
  "            ))}",
  "          </ScrollView>",
  "        ) : (",
  "          <ScrollView style={{ padding: 16 }}>",
  "            <View style={{ backgroundColor: '#fff', borderRadius: 8, 
marginBottom: 12 }}>",
  "              <Picker selectedValue={selectedEmployee} 
onValueChange={setSelectedEmployee}>",
  "                <Picker.Item label='-- Select Employee --' value='' 
/>",
  "                {employees.map((emp: any) => <Picker.Item key={emp._id} 
label={emp.name} value={emp._id} />)}",
  "              </Picker>",
  "            </View>",
  "            {selectedEmployee && (",
  "              <Calendar",
  "                current={selectedMonth + '-01'}",
  "                markedDates={markedDates}",
  "                onDayPress={(day: any) => { 
setSelectedDate(day.dateString); setShowStatusPicker(true); }}",
  "                onMonthChange={(month: any) => 
setSelectedMonth(month.year + '-' + String(month.month).padStart(2, 
'0'))}",
  "                theme={{ selectedDayBackgroundColor: '#D32F2F', 
todayTextColor: '#D32F2F', arrowColor: '#D32F2F' }}",
  "                style={{ borderRadius: 12 }}",
  "              />",
  "            )}",
  "          </ScrollView>",
  "        )}",
  "        {view === 'list' && <FAB icon='plus' style={{ position: 
'absolute', right: 16, bottom: 16, backgroundColor: '#D32F2F' }} 
onPress={() => { resetForm(); setShowModal(true); }} />}",
  "        <Portal>",
  "          <Modal visible={showModal} onDismiss={resetForm} 
contentContainerStyle={{ backgroundColor: '#fff', padding: 20, margin: 20, 
borderRadius: 12 }}>",
  "            <ScrollView>",
  "              <Text style={{ fontSize: 20, fontWeight: 'bold', 
marginBottom: 16 }}>{editingEmployee ? 'Edit' : 'Add'} Employee</Text>",
  "              <TextInput label='Name' value={formName} 
onChangeText={setFormName} mode='outlined' style={{ marginBottom: 12 }} 
/>",
  "              {!editingEmployee && <TextInput label='Username' 
value={formUsername} onChangeText={setFormUsername} mode='outlined' 
style={{ marginBottom: 12 }} autoCapitalize='none' />}",
  "              {!editingEmployee && <TextInput label='Password' 
value={formPassword} onChangeText={setFormPassword} mode='outlined' 
style={{ marginBottom: 12 }} secureTextEntry />}",
  "              <TextInput label='Daily Salary (₹)' value={formSalary} 
onChangeText={setFormSalary} mode='outlined' style={{ marginBottom: 12 }} 
keyboardType='numeric' />",
  "              <View style={{ flexDirection: 'row', alignItems: 
'center', marginBottom: 16 }}><Text style={{ flex: 1 }}>Double 
Concept</Text><Switch value={formDoubleEnabled} 
onValueChange={setFormDoubleEnabled} color='#D32F2F' /></View>",
  "              {editingEmployee && (",
  "                <View style={{ marginBottom: 16 }}>",
  "                  <Text style={{ fontWeight: 'bold', color: '#FF9800', 
marginBottom: 8 }}>Reset Password</Text>",
  "                  <TextInput label='New Password' 
value={newEmployeePassword} onChangeText={setNewEmployeePassword} 
mode='outlined' secureTextEntry style={{ marginBottom: 8 }} />",
  "                  <Button mode='contained' 
onPress={handleResetEmployeePassword} loading={resettingPassword} 
buttonColor='#FF9800'>Reset</Button>",
  "                </View>",
  "              )}",
  "              <Button mode='contained' onPress={handleCreateOrUpdate} 
buttonColor='#D32F2F'>Save</Button>",
  "            </ScrollView>",
  "          </Modal>",
  "        </Portal>",
  "        <Portal>",
  "          <Modal visible={showStatusPicker} onDismiss={() => 
setShowStatusPicker(false)} contentContainerStyle={{ backgroundColor: 
'#fff', padding: 20, margin: 20, borderRadius: 12 }}>",
  "            <Text style={{ fontSize: 18, fontWeight: 'bold', 
marginBottom: 16 }}>Mark: {selectedDate}</Text>",
  "            <TextInput label='Check-in (HH:mm)' value={customTime} 
onChangeText={setCustomTime} mode='outlined' style={{ marginBottom: 16 }} 
/>",
  "            {['present', 'half-day', 'absent', 'leave', 
'holiday'].map(s => (",
  "              <Button key={s} mode='outlined' onPress={() => 
handleMarkAttendance(s)} style={{ marginBottom: 8 
}}>{s.toUpperCase()}</Button>",
  "            ))}",
  "          </Modal>",
  "        </Portal>",
  "      </View>",
  "    </Provider>",
  "  );",
  "}"
];

// 2. app/admin/settings.tsx (Location, Holidays, Broadcast Notice)
const adminSettings = [
  "import React, { useState, useEffect } from 'react';",
  "import { View, ScrollView, Alert, Keyboard } from 'react-native';",
  "import { Text, TextInput, Button, Card, Provider, MD3LightTheme } from 
'react-native-paper';",
  "import { useAuth } from '../../src/context/AuthContext';",
  "import { api } from '../../src/services/api';",
  "import * as Location from 'expo-location';",
  "",
  "export default function SettingsScreen() {",
  "  const { token, logout } = useAuth();",
  "  const [loading, setLoading] = useState(false);",
  "  const [lat, setLat] = useState(''); const [lng, setLng] = 
useState(''); const [radius, setRadius] = useState('100');",
  "  const [holidayDate, setHolidayDate] = useState(''); const 
[holidayReason, setHolidayReason] = useState('');",
  "  const [noticeText, setNoticeText] = useState('');",
  "",
  "  useEffect(() => {",
  "    api.getSetting('showroomLocation').then(r => { if(r?.value) { 
setLat(String(r.value.latitude||'')); 
setLng(String(r.value.longitude||'')); 
setRadius(String(r.value.radius||'100')); } });",
  "    const d = new Date(); d.setTime(d.getTime() + 3600000 * 5.5);",
  "    setHolidayDate(d.getFullYear() + '-' + 
String(d.getMonth()+1).padStart(2,'0') + '-' + 
String(d.getDate()).padStart(2,'0'));",
  "  }, []);",
  "",
  "  const handleSaveLocation = async () => {",
  "    try { await api.updateSetting(token!, 'showroomLocation', { 
latitude: parseFloat(lat), longitude: parseFloat(lng), radius: 
parseFloat(radius) }); Alert.alert('Success', 'Location saved'); } 
catch(e:any) { Alert.alert('Error', e.message); }",
  "  };",
  "",
  "  const handleMarkHoliday = async () => {",
  "    try { await api.markHoliday(token!, holidayDate, holidayReason); 
Alert.alert('Success', 'Holiday marked'); setHolidayReason(''); } 
catch(e:any) { Alert.alert('Error', e.message); }",
  "  };",
  "",
  "  const handleBroadcast = async () => {",
  "    Keyboard.dismiss();",
  "    if(!noticeText) return Alert.alert('Error', 'Enter notice');",
  "    try {",
  "      let current = []; try { const r = await 
api.getSetting('notices'); if(r?.value) current = r.value; } catch(e) {}",
  "      const updated = [{ id: Date.now().toString(), message: 
noticeText, createdAt: new Date().toISOString() }, ...current].slice(0, 
50);",
  "      await api.updateSetting(token!, 'notices', updated);",
  "      Alert.alert('Success', 'Notice broadcasted!'); 
setNoticeText('');",
  "    } catch(e:any) { Alert.alert('Error', e.message); }",
  "  };",
  "",
  "  const redTheme = { ...MD3LightTheme, colors: { 
...MD3LightTheme.colors, primary: '#D32F2F' } };",
  "",
  "  return (",
  "    <Provider theme={redTheme}>",
  "      <ScrollView style={{ flex: 1, backgroundColor: '#f5f5f5', 
padding: 16 }}>",
  "        <Card style={{ marginBottom: 16, backgroundColor: '#fff' 
}}><Card.Title title='Broadcast Notice' /><Card.Content><TextInput 
label='Message' value={noticeText} onChangeText={setNoticeText} 
mode='outlined' multiline style={{ marginBottom: 12 }}/><Button 
mode='contained' onPress={handleBroadcast} 
buttonColor='#D32F2F'>Send</Button></Card.Content></Card>",
  "        <Card style={{ marginBottom: 16, backgroundColor: '#fff' 
}}><Card.Title title='Showroom Location' /><Card.Content><TextInput 
label='Latitude' value={lat} onChangeText={setLat} mode='outlined' 
style={{ marginBottom: 8 }}/><TextInput label='Longitude' value={lng} 
onChangeText={setLng} mode='outlined' style={{ marginBottom: 8 
}}/><TextInput label='Radius' value={radius} onChangeText={setRadius} 
mode='outlined' style={{ marginBottom: 12 }}/><Button mode='contained' 
onPress={handleSaveLocation} buttonColor='#D32F2F'>Save 
Location</Button></Card.Content></Card>",
  "        <Card style={{ marginBottom: 16, backgroundColor: '#fff' 
}}><Card.Title title='Mark Holiday' /><Card.Content><TextInput 
label='Date' value={holidayDate} onChangeText={setHolidayDate} 
mode='outlined' style={{ marginBottom: 8 }}/><TextInput label='Reason' 
value={holidayReason} onChangeText={setHolidayReason} mode='outlined' 
style={{ marginBottom: 12 }}/><Button mode='contained' 
onPress={handleMarkHoliday} buttonColor='#D32F2F'>Mark 
Holiday</Button></Card.Content></Card>",
  "        <Button mode='contained' onPress={logout} buttonColor='#F44336' 
style={{ marginTop: 12, marginBottom: 40 }}>Logout</Button>",
  "      </ScrollView>",
  "    </Provider>",
  "  );",
  "}"
];

// 3. app/employee/attendance.tsx (Staff Calendar View with 173-Year Fix)
const employeeAttendance = [
  "import React, { useState, useEffect } from 'react';",
  "import { View, ScrollView, RefreshControl } from 'react-native';",
  "import { Text, Card, Chip, Provider, MD3LightTheme } from 
'react-native-paper';",
  "import { useAuth } from '../../src/context/AuthContext';",
  "import { api } from '../../src/services/api';",
  "import { Calendar } from 'react-native-calendars';",
  "",
  "const STATUS_COLORS = { present: { color: '#4CAF50' }, 'half-day': { 
color: '#FF9800' }, absent: { color: '#F44336' }, leave: { color: 
'#2196F3' }, holiday: { color: '#9C27B0' } };",
  "",
  "export default function AttendanceScreen() {",
  "  const { token } = useAuth();",
  "  const [month, setMonth] = useState(() => { const d=new Date(); 
d.setTime(d.getTime()+3600000*5.5); return 
d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0'); });",
  "  const [records, setRecords] = useState([]);",
  "  const [marks, setMarks] = useState({});",
  "",
  "  const load = async () => {",
  "    try {",
  "      const data = await api.getMyAttendance(token, month);",
  "      setRecords(data);",
  "      const m: any = {};",
  "      data.forEach((r: any) => { if(STATUS_COLORS[r.status as keyof 
typeof STATUS_COLORS]) m[r.date] = { selected: true, selectedColor: 
STATUS_COLORS[r.status as keyof typeof STATUS_COLORS].color }; });",
  "      setMarks(m);",
  "    } catch(e) {}",
  "  };",
  "  useEffect(() => { load(); }, [month]);",
  "",
  "  return (",
  "    <Provider theme={{ ...MD3LightTheme, colors: { 
...MD3LightTheme.colors, primary: '#D32F2F' } }}>",
  "      <ScrollView style={{ flex: 1, backgroundColor: '#f5f5f5', 
padding: 12 }}>",
  "        <Card style={{ marginBottom: 12, backgroundColor: '#fff' }}>",
  "          <Card.Content>",
  "            <Calendar current={month + '-01'} markedDates={marks} 
onMonthChange={(m: any) => setMonth(m.year + '-' + 
String(m.month).padStart(2,'0'))} theme={{ selectedDayBackgroundColor: 
'#D32F2F', todayTextColor: '#D32F2F', arrowColor: '#D32F2F' }} style={{ 
borderRadius: 12 }} />",
  "          </Card.Content>",
  "        </Card>",
  "        {records.map((r: any, i) => (",
  "          <Card key={i} style={{ marginBottom: 8, backgroundColor: 
'#fff' }}><Card.Content style={{ flexDirection: 'row', justifyContent: 
'space-between', alignItems: 'center' }}><Text style={{ fontWeight: 'bold' 
}}>{r.date}</Text><Chip>{r.status}</Chip></Card.Content></Card>",
  "        ))}",
  "        <View style={{ height: 40 }} />",
  "      </ScrollView>",
  "    </Provider>",
  "  );",
  "}"
];

// 4. app/admin/notices.tsx (Admin Notice Board)
const adminNotices = [
  "import React, { useState, useEffect } from 'react';",
  "import { View, ScrollView, Alert, RefreshControl } from 
'react-native';",
  "import { Text, Card, Button, Provider, MD3LightTheme } from 
'react-native-paper';",
  "import { useAuth } from '../../src/context/AuthContext';",
  "import { api } from '../../src/services/api';",
  "",
  "export default function AdminNotices() {",
  "  const { token } = useAuth();",
  "  const [notices, setNotices] = useState([]);",
  "",
  "  const load = async () => {",
  "    try { const r = await api.getSetting('notices'); if(r?.value) 
setNotices(Array.isArray(r.value)?r.value:[]); } catch(e) {}",
  "  };",
  "  useEffect(() => { load(); }, []);",
  "",
  "  const handleDelete = (id: string) => {",
  "    Alert.alert('Confirm', 'Delete Notice?', [{ text: 'Cancel' }, { 
text: 'Delete', onPress: async () => {",
  "      try { const u = notices.filter((n:any)=>n.id!==id); await 
api.updateSetting(token!, 'notices', u); setNotices(u); } catch(e) {}",
  "    }}]);",
  "  };",
  "",
  "  return (",
  "    <Provider theme={{ ...MD3LightTheme, colors: { 
...MD3LightTheme.colors, primary: '#D32F2F' } }}>",
  "      <ScrollView style={{ padding: 16 }}>",
  "        {notices.map((n:any) => (",
  "          <Card key={n.id} style={{ marginBottom: 12, backgroundColor: 
'#fff' }}>",
  "             <Card.Content>",
  "               <Text style={{ fontWeight: 'bold', color: '#D32F2F', 
marginBottom: 8 }}>STORE ANNOUNCEMENT</Text>",
  "               <Text style={{ fontSize: 16 }}>{n.message}</Text>",
  "               <Button mode='text' onPress={() => handleDelete(n.id)} 
textColor='#F44336' style={{ alignSelf: 'flex-end', marginTop: 8 
}}>Delete</Button>",
  "             </Card.Content>",
  "          </Card>",
  "        ))}",
  "      </ScrollView>",
  "    </Provider>",
  "  );",
  "}"
];

// 5. app/employee/notices.tsx (Staff Notice Board)
const empNotices = [
  "import React, { useState, useEffect } from 'react';",
  "import { View, ScrollView, RefreshControl } from 'react-native';",
  "import { Text, Card, Provider, MD3LightTheme } from 
'react-native-paper';",
  "import { api } from '../../src/services/api';",
  "",
  "export default function EmpNotices() {",
  "  const [notices, setNotices] = useState([]);",
  "",
  "  const load = async () => {",
  "    try { const r = await api.getSetting('notices'); if(r?.value) 
setNotices(Array.isArray(r.value)?r.value:[]); } catch(e) {}",
  "  };",
  "  useEffect(() => { load(); }, []);",
  "",
  "  return (",
  "    <Provider theme={{ ...MD3LightTheme, colors: { 
...MD3LightTheme.colors, primary: '#D32F2F' } }}>",
  "      <ScrollView style={{ padding: 16 }}>",
  "        {notices.map((n:any) => (",
  "          <Card key={n.id} style={{ marginBottom: 12, backgroundColor: 
'#fff' }}>",
  "             <Card.Content>",
  "               <Text style={{ fontWeight: 'bold', color: '#D32F2F', 
marginBottom: 8 }}>STORE ANNOUNCEMENT</Text>",
  "               <Text style={{ fontSize: 16 }}>{n.message}</Text>",
  "             </Card.Content>",
  "          </Card>",
  "        ))}",
  "      </ScrollView>",
  "    </Provider>",
  "  );",
  "}"
];

// Execute writes safely
writeFile('app/admin/employees.tsx', adminEmployees);
writeFile('app/admin/settings.tsx', adminSettings);
writeFile('app/employee/attendance.tsx', employeeAttendance);
writeFile('app/admin/notices.tsx', adminNotices);
writeFile('app/employee/notices.tsx', empNotices);

console.log('Core Tabs Restored Perfectly!');
