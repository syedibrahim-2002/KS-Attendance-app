#!/bin/bash

# Ensure output directories exist before writing files
mkdir -p app/admin
mkdir -p app/employee

# 1. Generate app/admin/notices.tsx as a clean UTF-8 plain-text file
cat << 'EOF' > app/admin/notices.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { Card, IconButton, Divider, Provider, MD3LightTheme } from 'react-native-paper';
import { useAuth } from '../../src/context/AuthContext';
import { api } from '../../src/services/api';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

export default function AdminNoticesScreen() {
  const { token } = useAuth();
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [notices, setNotices] = useState<any[]>([]);

  useEffect(() => {
    fetchNotices();
  }, []);

  const fetchNotices = async () => {
    try {
      const response = await api.getSetting('notices');
      if (response && response.value) {
        setNotices(Array.isArray(response.value) ? response.value : []);
      } else {
        setNotices([]);
      }
    } catch (error) {
      console.error('Failed to fetch notices:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    fetchNotices();
  };

  const handleDeleteNotice = async (noticeId: string) => {
    Alert.alert(
      'Delete Notice',
      'Are you sure you want to delete this notice for all employees?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            setLoading(true);
            try {
              const updatedNotices = notices.filter((notice) => notice.id !== noticeId);
              await api.updateSetting(token!, 'notices', updatedNotices);
              setNotices(updatedNotices);
              Alert.alert('Success', 'Notice deleted successfully');
            } catch (error) {
              Alert.alert('Error', 'Failed to delete notice');
            } finally {
              setLoading(false);
            }
          },
        },
      ]
    );
  };

  const formatISTDate = (isoString: string) => {
    if (!isoString) return '';
    try {
      return new Date(isoString).toLocaleDateString('en-IN', {
        timeZone: 'Asia/Kolkata',
        weekday: 'short',
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
      });
    } catch (error) {
      return isoString;
    }
  };

  if (loading && !refreshing) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#D32F2F" />
      </View>
    );
  }

  const redTheme = {
    ...MD3LightTheme,
    colors: {
      ...MD3LightTheme.colors,
      primary: '#D32F2F',
    },
  };

  return (
    <Provider theme={redTheme}>
      <View style={styles.screen}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <MaterialCommunityIcons name="arrow-left" size={24} color="#333" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Notice Board (Admin)</Text>
        </View>

        <ScrollView
          contentContainerStyle={styles.scrollContent}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        >
          <View style={styles.infoCard}>
            <MaterialCommunityIcons name="information" size={20} color="#1976D2" />
            <Text style={styles.infoText}>
              All published store announcements sent to staff are archived below.
            </Text>
          </View>

          {notices.length === 0 ? (
            <View style={styles.emptyContainer}>
              <MaterialCommunityIcons name="bullhorn-outline" size={60} color="#ccc" />
              <Text style={styles.emptyText}>No notices published yet</Text>
              <Text style={styles.emptySubText}>
                Go to Settings > Broadcast Notice to publish a new announcement.
              </Text>
            </View>
          ) : (
            notices.map((notice) => (
              <Card key={notice.id} style={styles.card}>
                <Card.Content>
                  <View style={styles.noticeHeader}>
                    <View style={styles.badge}>
                      <MaterialCommunityIcons name="bullhorn" size={16} color="#D32F2F" />
                      <Text style={styles.badgeText}>STORE ANNOUNCEMENT</Text>
                    </View>
                    <IconButton
                      icon="delete"
                      iconColor="#F44336"
                      size={20}
                      onPress={() => handleDeleteNotice(notice.id)}
                      style={styles.deleteButton}
                    />
                  </View>

                  <Text style={styles.messageText}>{notice.message}</Text>
                  <Divider style={styles.divider} />
                  
                  <View style={styles.footerRow}>
                    <MaterialCommunityIcons name="clock-outline" size={14} color="#666" />
                    <Text style={styles.dateText}>
                      Published: {formatISTDate(notice.createdAt)}
                    </Text>
                  </View>
                </Card.Content>
              </Card>
            ))
          )}
          <View style={{ height: 40 }} />
        </ScrollView>
      </View>
    </Provider>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#f5f5f5' },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', padding: 16, backgroundColor: '#fff', 
elevation: 2, borderBottomWidth: 1, borderBottomColor: '#eee' },
  backButton: { padding: 4, marginRight: 16 },
  headerTitle: { fontSize: 18, fontWeight: 'bold', color: '#333' },
  scrollContent: { padding: 16 },
  infoCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#E3F2FD', borderRadius: 
8, padding: 12, marginBottom: 16 },
  infoText: { marginLeft: 8, flex: 1, color: '#1976D2', fontSize: 13, fontWeight: '500' },
  emptyContainer: { alignItems: 'center', justifyContent: 'center', paddingVertical: 60 },
  emptyText: { fontSize: 16, fontWeight: 'bold', color: '#666', marginTop: 12 },
  emptySubText: { fontSize: 12, color: '#999', marginTop: 4, textAlign: 'center' },
  card: { marginBottom: 12, backgroundColor: '#fff', elevation: 2 },
  noticeHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', 
marginBottom: 10 },
  badge: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#FFEBEE', 
paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6 },
  badgeText: { fontSize: 10, fontWeight: 'bold', color: '#D32F2F', marginLeft: 6 },
  deleteButton: { margin: 0, padding: 0 },
  messageText: { fontSize: 15, color: '#333', lineHeight: 22 },
  divider: { marginVertical: 12 },
  footerRow: { flexDirection: 'row', alignItems: 'center' },
  dateText: { fontSize: 12, color: '#666', marginLeft: 6 },
});
EOF

# 2. Generate app/employee/notices.tsx as a clean UTF-8 plain-text file
cat << 'EOF' > app/employee/notices.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { Card, Divider, Provider, MD3LightTheme } from 'react-native-paper';
import { api } from '../../src/services/api';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

export default function EmployeeNoticesScreen() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [notices, setNotices] = useState<any[]>([]);

  useEffect(() => {
    fetchNotices();
  }, []);

  const fetchNotices = async () => {
    try {
      const response = await api.getSetting('notices');
      if (response && response.value) {
        setNotices(Array.isArray(response.value) ? response.value : []);
      } else {
        setNotices([]);
      }
    } catch (error) {
      console.error('Failed to fetch notices:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    fetchNotices();
  };

  const formatISTDate = (isoString: string) => {
    if (!isoString) return '';
    try {
      return new Date(isoString).toLocaleDateString('en-IN', {
        timeZone: 'Asia/Kolkata',
        weekday: 'short',
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
      });
    } catch (error) {
      return isoString;
    }
  };

  if (loading && !refreshing) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#D32F2F" />
      </View>
    );
  }

  const redTheme = {
    ...MD3LightTheme,
    colors: {
      ...MD3LightTheme.colors,
      primary: '#D32F2F',
    },
  };

  return (
    <Provider theme={redTheme}>
      <View style={styles.screen}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <MaterialCommunityIcons name="arrow-left" size={24} color="#333" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Store Notice Board</Text>
        </View>

        <ScrollView
          contentContainerStyle={styles.scrollContent}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        >
          <View style={styles.infoCard}>
            <MaterialCommunityIcons name="bullhorn" size={20} color="#D32F2F" />
            <Text style={styles.infoText}>
              Keep up with the latest store instructions and announcements from management.
            </Text>
          </View>

          {notices.length === 0 ? (
            <View style={styles.emptyContainer}>
              <MaterialCommunityIcons name="clipboard-text-outline" size={60} color="#ccc" />
              <Text style={styles.emptyText}>Notice board is clear</Text>
              <Text style={styles.emptySubText}>
                No new announcements published by management at the moment.
              </Text>
            </View>
          ) : (
            notices.map((notice) => (
              <Card key={notice.id} style={styles.card}>
                <Card.Content>
                  <View style={styles.noticeHeader}>
                    <View style={styles.badge}>
                      <MaterialCommunityIcons name="bullhorn" size={16} color="#D32F2F" />
                      <Text style={styles.badgeText}>STORE ANNOUNCEMENT</Text>
                    </View>
                  </View>

                  <Text style={styles.messageText}>{notice.message}</Text>
                  <Divider style={styles.divider} />
                  
                  <View style={styles.footerRow}>
                    <MaterialCommunityIcons name="clock-outline" size={14} color="#666" />
                    <Text style={styles.dateText}>
                      Published: {formatISTDate(notice.createdAt)}
                    </Text>
                  </View>
                </Card.Content>
              </Card>
            ))
          )}
          <View style={{ height: 40 }} />
        </ScrollView>
      </View>
    </Provider>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#f5f5f5' },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', padding: 16, backgroundColor: '#fff', 
elevation: 2, borderBottomWidth: 1, borderBottomColor: '#eee' },
  backButton: { padding: 4, marginRight: 16 },
  headerTitle: { fontSize: 18, fontWeight: 'bold', color: '#333' },
  scrollContent: { padding: 16 },
  infoCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#FFEBEE', borderRadius: 
8, padding: 12, marginBottom: 16 },
  infoText: { marginLeft: 8, flex: 1, color: '#D32F2F', fontSize: 13, fontWeight: '500' },
  emptyContainer: { alignItems: 'center', justifyContent: 'center', paddingVertical: 60 },
  emptyText: { fontSize: 16, fontWeight: 'bold', color: '#666', marginTop: 12 },
  emptySubText: { fontSize: 12, color: '#999', marginTop: 4, textAlign: 'center' },
  card: { marginBottom: 12, backgroundColor: '#fff', elevation: 2 },
  noticeHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', 
marginBottom: 12 },
  badge: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#FFEBEE', 
paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6 },
  badgeText: { fontSize: 10, fontWeight: 'bold', color: '#D32F2F', marginLeft: 6 },
  messageText: { fontSize: 15, color: '#333', lineHeight: 22 },
  divider: { marginVertical: 12 },
  footerRow: { flexDirection: 'row', alignItems: 'center' },
  dateText: { fontSize: 12, color: '#666', marginLeft: 6 },
});
EOF

echo "SUCCESS: TSX Files successfully written as clean UTF-8 plain-text files!"
