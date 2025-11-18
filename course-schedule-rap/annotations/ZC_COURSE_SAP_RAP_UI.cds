@Metadata.layer: #CORE

@UI: {
    headerInfo: {
        typeName: 'Course',
        typeNamePlural: 'Courses',
        title: { type: #STANDARD, value: 'courseid' }
    },
    presentationVariant: [{
        sortOrder: [{ by: 'courseid', direction: #ASC }]
    }]
}

annotate entity ZC_COURSE_SAP_RAP with
{

    @UI.facet: [{
        id: 'Course',
        purpose: #STANDARD,
        type: #IDENTIFICATION_REFERENCE,
        label: 'Course Details',
        position: 10
    },
    {
        id: 'Schedule',
        purpose: #STANDARD,
        type: #LINEITEM_REFERENCE,
        label: 'Schedule List',
        position: 20,
        targetElement: '_SCHEDULE'
    }]

    @UI.hidden: true
    COURSEUUID;

    @UI: {
        lineItem:       [{ position: 10, label: 'Course ID' }],
        identification: [{ position: 10, label: 'Course ID' }],
        selectionField: [{ position: 10 }]
    }
    courseid;

    @UI: {
        lineItem:       [{ position: 20, label: 'Course Name' }],
        identification: [{ position: 20, label: 'Course Name' }],
        selectionField: [{ position: 20 }]
    }
    COURSENAME;

    @UI: {
        lineItem:       [{ position: 30, label: 'Country' }],
        identification: [{ position: 30, label: 'Country' }],
        selectionField: [{ position: 30 }]
    }
    COUNTRY;

    @UI: {
        lineItem:       [{ position: 40, label: 'Length' }],
        identification: [{ position: 40, label: 'Length' }]
    }
    COURSELENGHT;

    @UI: {
        lineItem:       [{ position: 50, label: 'Price' }],
        identification: [{ position: 50, label: 'Price' }]
    }
    PRICE;

    @UI: {
        lineItem:       [{ position: 60, label: 'Currency' }],
        identification: [{ position: 60, label: 'Currency' }]
    }
    CURRENCYCODE;

    @UI: {
        identification: [{ position: 70, label: 'Last Changed At' }]
    }
    LASTCHANGEDAT;

}
