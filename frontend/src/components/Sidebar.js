import React from 'react';
import { Link } from 'react-router-dom';
import { FaBars } from 'react-icons/fa';
import './Sidebar.css';

const Sidebar = ({ isOpen, toggleSidebar }) => {
  return (
    <div className={`sidebar ${isOpen ? 'open' : ''}`}>
      <div className="sidebar-header">
        <span>IFrame</span>
        <FaBars className="hamburger" onClick={toggleSidebar} />       
      </div>
      <ul>
        <li><Link to="/users">User</Link></li>
        <li><Link to="/employees">Employee</Link></li>
      </ul>
    </div>
  );
};

export default Sidebar;
