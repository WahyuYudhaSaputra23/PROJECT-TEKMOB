import React from 'react';
import './Table.css';

const EmployeeTable = ({ employees }) => {
  return (
    <table className="table">
      <thead>
        <tr>
          <th>User ID</th>
          <th>Full Name</th>
          <th>User Role</th>
          <th>Jobdesk</th>
          <th>Date</th>
          <th>Branch</th>
          <th>Check In</th>
          <th>Check Out</th>
          <th>Notes</th>
          <th>Shift</th>
          <th>Work Duration</th>
        </tr>
      </thead>
      <tbody>
        {employees.map(employee => (
          <tr key={employee._id}>
            <td>{employee.userID ? employee.userID._id : 'N/A'}</td>
            <td>{employee.userID ? employee.userID.fullName : 'N/A'}</td>
            <td>{employee.userRole}</td>
            <td>{employee.jobdesk}</td>
            <td>{new Date(employee.date).toLocaleDateString()}</td>
            <td>{employee.branch ? employee.branch.name : 'N/A'}</td>
            <td>{employee.checkIn ? new Date(employee.checkIn).toLocaleTimeString() : 'N/A'}</td>
            <td>{employee.checkOut ? new Date(employee.checkOut).toLocaleTimeString() : 'N/A'}</td>
            <td>{employee.notes}</td>
            <td>{employee.shiftIDs.map(shiftID => `${shiftID.shiftName}`).join(', ')}</td>
            <td>{employee.workDuration}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default EmployeeTable;
