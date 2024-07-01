import React, { useState } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import UserPage from './pages/UserPage';
import EmployeePage from './pages/EmployeePage';
import EditUserPage from './pages/EditUserPage';
import AddUserPage from './pages/AddUserPage';
import './App.css';

const App = () => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleSidebar = () => {
    setIsOpen(!isOpen);
  };

  return (
    <Router>
      <div className="app">
        <Sidebar isOpen={isOpen} toggleSidebar={toggleSidebar} />
        <div className={`main-content ${isOpen ? 'shifted' : ''}`}>
          <Routes>
            <Route path="/users" element={<UserPage />} />
            <Route path="/employees" element={<EmployeePage />} />
            <Route path="/add-user" element={<AddUserPage />} />
            <Route path="/edit-user/:id" element={<EditUserPage />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
};

export default App;
