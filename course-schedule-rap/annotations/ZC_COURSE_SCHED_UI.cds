' begin of daniele 2025-11-19

@Metadata.layer: #CORE

@UI: {
    headerInfo: {
        typeName: 'Schedule',
        typeNamePlural: 'Schedules',
        title: { type: #STANDARD, value: 'coursebegin' }
    },

    presentationVariant: [{
        sortOrder: [{ by: 'coursebegin', direction: #ASC }]
    }]
}

annotate entity ZC_COURSE_SCHED with
{

    @UI.facet: [{
        id: 'ScheduleDetails',
        purpose: #STANDARD,
        type: #IDENTIFICATION_REFERENCE,
        label: 'Schedule Details',
        position: 10
    }]

    @UI.hidden: true
    scheduleuuid;

    @UI: {
        lineItem:       [{ position: 10, label: 'Begin' }],
        identification: [{ position: 10, label: 'Begin' }]
    }
    coursebegin;

    @UI.hidden: true
    courseuuid;

    @UI: {
        lineItem:       [{ position: 20, label: 'Location' }],
        identification: [{ position: 20, label: 'Location' }]
    }
    location;

    @UI: {
        lineItem:       [{ position: 30, label: 'Instructor' }],
        identification: [{ position: 30, label: 'Instructor' }]
    }
    trainer;

    @UI: {
        lineItem:       [{ position: 40, label: 'Online' }],
        identification: [{ position: 40, label: 'Online' }]
    }
    isonline;

    @UI: {
        lineItem:       [{ position: 50, label: 'Last Changed' }],
        identification: [{ position: 50, label: 'Last Changed' }]
    }
    lastchangedat;

    @UI: {
        lineItem:       [{ position: 60, label: 'Local Last Changed' }],
        identification: [{ position: 60, label: 'Local Last Changed' }]
    }
    LOCALLASTCHANGEDAT;

}

' end of daniele 2025-11-19
