#!/bin/bash

mkdir -p app/admin
mkdir -p app/employee

cat << 'EOF' > app/admin/_layout.tsx
import React from 'react';
import { Tabs } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
export default function AdminLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#FFFFFF', 
tabBarInactiveTintColor: '#FFCDD2', tabBarStyle: { backgroundColor: 
'#D32F2F', height: 60, paddingBottom: 6 }, headerStyle: { backgroundColor: 
'#D32F2F' }, headerTintColor: '#FFFFFF', headerTitleStyle: { fontWeight: 
'bold' } }}>
      <Tabs.Screen name="index" options={{ title: 'Dashboard', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="view-dashboard" size={24} 
color={color} /> }} />
      <Tabs.Screen name="employees" options={{ title: 'Employees', 
tabBarIcon: ({ color }) => <MaterialCommunityIcons name="account-group" 
size={24} color={color} /> }} />
      <Tabs.Screen name="leaves" options={{ title: 'Leaves', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="calendar-check" size={24} 
color={color} /> }} />
      <Tabs.Screen name="reports" options={{ title: 'Reports', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="file-chart" size={24} 
color={color} /> }} />
      <Tabs.Screen name="settings" options={{ title: 'Settings', 
tabBarIcon: ({ color }) => <MaterialCommunityIcons name="cog" size={24} 
color={color} /> }} />
      <Tabs.Screen name="notices" options={{ title: 'Notices', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="bullhorn" size={24} 
color={color} /> }} />
      <Tabs.Screen name="notifications" options={{ href: null, title: 
'Notifications' }} />
    </Tabs>
  );
}
EOF

cat << 'EOF' > app/employee/_layout.tsx
import React from 'react';
import { Tabs } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
export default function EmployeeLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#FFFFFF', 
tabBarInactiveTintColor: '#FFCDD2', tabBarStyle: { backgroundColor: 
'#D32F2F', height: 60, paddingBottom: 6 }, headerStyle: { backgroundColor: 
'#D32F2F' }, headerTintColor: '#FFFFFF', headerTitleStyle: { fontWeight: 
'bold' } }}>
      <Tabs.Screen name="index" options={{ title: 'Home', tabBarIcon: ({ 
color }) => <MaterialCommunityIcons name="home" size={24} color={color} /> 
}} />
      <Tabs.Screen name="attendance" options={{ title: 'Attendance', 
tabBarIcon: ({ color }) => <MaterialCommunityIcons name="calendar-clock" 
size={24} color={color} /> }} />
      <Tabs.Screen name="leaves" options={{ title: 'Leaves', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="calendar-edit" size={24} 
color={color} /> }} />
      <Tabs.Screen name="salary" options={{ title: 'Salary', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="cash-multiple" size={24} 
color={color} /> }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="account" size={24} 
color={color} /> }} />
      <Tabs.Screen name="notices" options={{ title: 'Notices', tabBarIcon: 
({ color }) => <MaterialCommunityIcons name="bullhorn" size={24} 
color={color} /> }} />
      <Tabs.Screen name="notifications" options={{ href: null, title: 
'Notifications' }} />
      <Tabs.Screen name="loans" options={{ href: null, title: 'Loans' }} 
/>
      <Tabs.Screen name="advances" options={{ href: null, title: 
'Advances' }} />
    </Tabs>
  );
}
EOF

cat << 'EOF' > app/admin/index.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, RefreshControl } from 
'react-native';
import { Card, Button, Surface, Provider, MD3LightTheme } from 
'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useAuth } from '../../src/context/AuthContext';
import { api } from '../../src/services/api';
import { useRouter } from 'expo-router';

export default function AdminDashboard() {
  const { user, token } = useAuth();
  const router = useRouter();
  const [refreshing, setRefreshing] = useState(false);
  const [stats, setStats] = useState({ present: 0, pendingLeaves: 0, 
totalStaff: 0 });

  const loadStats = async () => {
    if (!token) return;
    try {
      const users = await api.getUsers(token);
      const leaves = await api.getAllLeaves(token, 'pending');
      const d = new Date();
      const utc = d.getTime() + (d.getTimezoneOffset() * 60000);
      const ist = new Date(utc + (3600000 * 5.5));
      const todayStr = `${ist.getFullYear()}-${String(ist.getMonth() + 
1).padStart(2, '0')}-${String(ist.getDate()).padStart(2, '0')}`;
      const attendance = await api.getAllAttendance(token, todayStr);
      const presentCount = attendance.filter((a: any) => a.status === 
'present' || a.status === 'half-day').length;
      setStats({ present: presentCount, pendingLeaves: leaves.length, 
totalStaff: users.filter((u: any) => u.role === 'employee').length });
    } catch (e) {}
  };

  useEffect(() => { loadStats(); }, []);
  const onRefresh = async () => { setRefreshing(true); await loadStats(); 
setRefreshing(false); };
  const redTheme = { ...MD3LightTheme, colors: { ...MD3LightTheme.colors, 
primary: '#D32F2F' } };

  return (
    <Provider theme={redTheme}>
      <View style={{ flex: 1, backgroundColor: '#f5f5f5' }}>
        <Surface style={{ padding: 20, backgroundColor: '#D32F2F', 
elevation: 4, borderBottomLeftRadius: 16, borderBottomRightRadius: 16 }}>
          <View style={{ flexDirection: 'row', justifyContent: 
'space-between', alignItems: 'center' }}>
            <View>
              <Text style={{ fontSize: 22, fontWeight: 'bold', color: 
'#fff' }}>Kalanjiyam Stores</Text>
              <Text style={{ fontSize: 13, color: '#FFCDD2', marginTop: 2 
}}>Admin Portal • {user?.name}</Text>
            </View>
            <TouchableOpacity onPress={() => 
router.push('/admin/notifications' as any)} style={{ padding: 4 }}>
              <MaterialCommunityIcons name="bell-ring" size={24} 
color="#fff" />
            </TouchableOpacity>
          </View>
        </Surface>

        <ScrollView style={{ flex: 1, padding: 12 }} 
refreshControl={<RefreshControl refreshing={refreshing} 
onRefresh={onRefresh} />}>
          <View style={{ flexDirection: 'row', justifyContent: 
'space-between', gap: 8, marginBottom: 12 }}>
            <View style={{ flex: 1, backgroundColor: '#fff', borderRadius: 
12, padding: 14, alignItems: 'center', borderLeftWidth: 4, 
borderLeftColor: '#4CAF50' }}>
              <MaterialCommunityIcons name="account-check" size={28} 
color="#4CAF50" />
              <Text style={{ fontSize: 20, fontWeight: 'bold', color: 
'#333' }}>{stats.present}</Text>
              <Text style={{ fontSize: 11, color: '#666' }}>Today 
Present</Text>
            </View>
            <View style={{ flex: 1, backgroundColor: '#fff', borderRadius: 
12, padding: 14, alignItems: 'center', borderLeftWidth: 4, 
borderLeftColor: '#FF9800' }}>
              <MaterialCommunityIcons name="calendar-alert" size={28} 
color="#FF9800" />
              <Text style={{ fontSize: 20, fontWeight: 'bold', color: 
'#333' }}>{stats.pendingLeaves}</Text>
              <Text style={{ fontSize: 11, color: '#666' }}>Pending 
Leaves</Text>
            </View>
            <View style={{ flex: 1, backgroundColor: '#fff', borderRadius: 
12, padding: 14, alignItems: 'center', borderLeftWidth: 4, 
borderLeftColor: '#D32F2F' }}>
              <MaterialCommunityIcons name="account-group" size={28} 
color="#D32F2F" />
              <Text style={{ fontSize: 20, fontWeight: 'bold', color: 
'#333' }}>{stats.totalStaff}</Text>
              <Text style={{ fontSize: 11, color: '#666' }}>Total 
Staff</Text>
            </View>
          </View>
          <Card style={{ marginBottom: 12, backgroundColor: '#fff' }}>
            <Card.Title title="Quick Actions" titleStyle={{ fontWeight: 
'bold' }} />
            <Card.Content style={{ flexDirection: 'row', gap: 8 }}>
              <Button mode="contained" buttonColor="#D32F2F" style={{ 
flex: 1 }} onPress={() => router.push('/admin/employees' as any)} 
icon="account-plus">Add Staff</Button>
              <Button mode="contained" buttonColor="#D32F2F" style={{ 
flex: 1 }} onPress={() => router.push('/admin/settings' as any)} 
icon="bullhorn">Notice</Button>
            </Card.Content>
          </Card>
          <View style={{ height: 40 }} />
        </ScrollView>
      </View>
    </Provider>
  );
}
EOF

cat << 'EOF' > app/employee/index.tsx
import React, { useState, useEffect } from 'react';
import { View, ScrollView, Alert, RefreshControl, TouchableOpacity } from 
'react-native';
import { Text, Button, Card, Surface, Provider, MD3LightTheme } from 
'react-native-paper';
import { useAuth } from '../../src/context/AuthContext';
import { api } from '../../src/services/api';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { requestLocationPermission, getCurrentLocation, isWithinShowroom } 
from '../../src/utils/location';
import { useRouter } from 'expo-router';

const getISTDateValues = () => {
  const now = new Date();
  const ist = new Date(now.getTime() + (5.5 * 60 * 60 * 1000));
  const weekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 
'Thursday', 'Friday', 'Saturday'];
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 
'July', 'August', 'September', 'October', 'November', 'December'];
  return {
    dateString: `${ist.getUTCFullYear()}-${String(ist.getUTCMonth() + 
1).padStart(2, '0')}-${String(ist.getUTCDate()).padStart(2, '0')}`,
    monthString: `${ist.getUTCFullYear()}-${String(ist.getUTCMonth() + 
1).padStart(2, '0')}`,
    displayString: `${weekDays[ist.getUTCDay()]} - 
${months[ist.getUTCMonth()]} ${ist.getUTCDate()}, ${ist.getUTCFullYear()}`
  };
};

export default function EmployeeHome() {
  const { user, token } = useAuth();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [todayAttendance, setTodayAttendance] = useState<any>(null);
  const [showroomLocation, setShowroomLocation] = useState<any>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [advances, setAdvances] = useState<any>(null);
  const [loans, setLoans] = useState<any[]>([]);

  const loadData = async () => {
    try {
      const settingResponse = await api.getSetting('showroomLocation');
      if (settingResponse && settingResponse.value) 
setShowroomLocation(settingResponse.value);
      const istVal = getISTDateValues();
      const attendanceRecords = await api.getMyAttendance(token!);
      setTodayAttendance(attendanceRecords.find((r: any) => r.date === 
istVal.dateString));
      setAdvances(await api.getUserAdvances(token!, user!._id, 
istVal.monthString));
      setLoans(await api.getUserLoans(token!, user!._id));
    } catch (error) {}
  };

  useEffect(() => { loadData(); }, []);
  const onRefresh = async () => { setRefreshing(true); await loadData(); 
setRefreshing(false); };

  const handleMarkAttendance = async () => {
    if (!showroomLocation) { Alert.alert('Error', 'Location Not Set'); 
return; }
    setLoading(true);
    try {
      const hasPerm = await requestLocationPermission();
      if (!hasPerm) return Alert.alert('Error', 'Permission Denied');
      const loc = await getCurrentLocation();
      if (!loc) return Alert.alert('Error', 'Failed to get GPS');
      if (!isWithinShowroom(loc.latitude, loc.longitude, 
showroomLocation.latitude, showroomLocation.longitude, 
showroomLocation.radius || 100)) {
        return Alert.alert('Location Mismatch', 'You must be inside the 
showroom');
      }
      const response = await api.markAttendance(token!, { status: 
'present', location: loc });
      Alert.alert('Success', `Attendance marked as 
${response.status.toUpperCase()}`, [{ text: 'OK', onPress: loadData }]);
    } catch (e: any) { Alert.alert('Error', e.message); } finally { 
setLoading(false); }
  };

  const redTheme = { ...MD3LightTheme, colors: { ...MD3LightTheme.colors, 
primary: '#D32F2F' } };

  return (
    <Provider theme={redTheme}>
      <View style={{ flex: 1, backgroundColor: '#f5f5f5' }}>
        <Surface style={{ padding: 20, backgroundColor: '#D32F2F', 
elevation: 4, borderBottomLeftRadius: 16, borderBottomRightRadius: 16 }}>
          <View style={{ flexDirection: 'row', justifyContent: 
'space-between', alignItems: 'center' }}>
            <View>
              <Text style={{ fontSize: 20, fontWeight: 'bold', color: 
'#fff' }}>Welcome, {user?.name}!</Text>
              <Text style={{ color: '#FFCDD2', fontSize: 13, marginTop: 2 
}}>Kalanjiyam Stores • Staff</Text>
              <Text style={{ color: '#FFCDD2', fontSize: 12, marginTop: 4 
}}>{getISTDateValues().displayString}</Text>
            </View>
            <TouchableOpacity onPress={() => 
router.push('/employee/notifications' as any)} style={{ padding: 4 }}>
              <MaterialCommunityIcons name="bell-ring" size={24} 
color="#fff" />
            </TouchableOpacity>
          </View>
        </Surface>

        <ScrollView style={{ padding: 12 }} 
refreshControl={<RefreshControl refreshing={refreshing} 
onRefresh={onRefresh} />}>
          <Card style={{ marginBottom: 12, backgroundColor: '#fff' }}>
            <Card.Content>
              <View style={{ alignItems: 'center', paddingVertical: 12 }}>
                <MaterialCommunityIcons name={todayAttendance ? 
'check-circle' : 'clock-alert'} size={56} color={todayAttendance ? 
'#4caf50' : '#666'} />
                <Text style={{ marginTop: 8, fontSize: 16, fontWeight: 
'bold' }}>{todayAttendance ? `TODAY: 
${todayAttendance.status.toUpperCase()}` : 'Attendance Not Marked'}</Text>
              </View>
              {!todayAttendance && <Button mode="contained" 
onPress={handleMarkAttendance} loading={loading} buttonColor="#D32F2F" 
icon="check-circle">Mark Attendance</Button>}
            </Card.Content>
          </Card>
          <Card style={{ marginBottom: 12, backgroundColor: '#fff' }}>
            <Card.Title title="This Month's Finances" titleStyle={{ 
fontWeight: 'bold' }} left={(props) => <MaterialCommunityIcons {...props} 
name="cash-multiple" color="#D32F2F" />} />
            <Card.Content>
              <View style={{ flexDirection: 'row', justifyContent: 
'space-between', gap: 8 }}>
                <View style={{ flex: 1, backgroundColor: '#fff3e0', 
padding: 14, borderRadius: 12, alignItems: 'center' }}>
                  <MaterialCommunityIcons name="cash-fast" size={28} 
color="#ff9800" />
                  <Text style={{ fontSize: 18, fontWeight: 'bold', color: 
'#333', marginTop: 4 }}>₹{advances?.totalThisMonth?.toFixed(0) || 
'0'}</Text>
                  <Text style={{ fontSize: 11, color: '#666' }}>Advances 
Taken</Text>
                </View>
                <View style={{ flex: 1, backgroundColor: '#ffebee', 
padding: 14, borderRadius: 12, alignItems: 'center' }}>
                  <MaterialCommunityIcons name="bank" size={28} 
color="#f44336" />
                  <Text style={{ fontSize: 18, fontWeight: 'bold', color: 
'#333', marginTop: 4 }}>{loans.find((l: any) => l.status === 'active') ? 
`₹${loans.find((l: any) => l.status === 
'active')?.remainingAmount.toFixed(0)}` : '-'}</Text>
                  <Text style={{ fontSize: 11, color: '#666' 
}}>{loans.find((l: any) => l.status === 'active') ? 'Loan Remaining' : 'No 
Active Loan'}</Text>
                </View>
              </View>
            </Card.Content>
          </Card>
        </ScrollView>
      </View>
    </Provider>
  );
}
EOF

cat << 'EOF' > app/admin/employees.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/admin/leaves.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/admin/reports.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/admin/settings.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/admin/notices.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/admin/notifications.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF

cat << 'EOF' > app/employee/attendance.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/employee/leaves.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/employee/salary.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/employee/profile.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/employee/notices.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/employee/notifications.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return 
<View><Text>Loading...</Text></View>; }
EOF
cat << 'EOF' > app/employee/loans.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return <View><Text>Hidden</Text></View>; 
}
EOF
cat << 'EOF' > app/employee/advances.tsx
import React from 'react'; import { View, Text } from 'react-native'; 
export default function Temp() { return <View><Text>Hidden</Text></View>; 
}
EOF

echo "Rescue Complete! Start the build now."
